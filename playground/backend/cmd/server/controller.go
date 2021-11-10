// Licensed to the Apache Software Foundation (ASF) under one or more
// contributor license agreements.  See the NOTICE file distributed with
// this work for additional information regarding copyright ownership.
// The ASF licenses this file to You under the Apache License, Version 2.0
// (the "License"); you may not use this file except in compliance with
// the License.  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package main

import (
	pb "beam.apache.org/playground/backend/internal/api/v1"
	"beam.apache.org/playground/backend/internal/cache"
	"beam.apache.org/playground/backend/internal/environment"
	"beam.apache.org/playground/backend/internal/errors"
	"beam.apache.org/playground/backend/internal/executors"
	"beam.apache.org/playground/backend/internal/fs_tool"
	"beam.apache.org/playground/backend/internal/logger"
	"beam.apache.org/playground/backend/internal/storage"
	"beam.apache.org/playground/backend/internal/validators"
	"context"
	"github.com/google/uuid"
)

// playgroundController processes `gRPC' requests from clients.
// Contains methods to process receiving code, monitor current status of code processing and receive compile/run output.
type playgroundController struct {
	env          *environment.Environment
	cacheService cache.Cache

	pb.UnimplementedPlaygroundServiceServer
}

// RunCode is running code from requests using a particular SDK
// - In case of incorrect sdk returns codes.InvalidArgument
// - In case of error during preparing files/folders returns codes.Internal
// - In case of no errors saves playground.Status_STATUS_EXECUTING as cache.Status into cache and sets expiration time
//   for all cache values which will be saved into cache during processing received code.
//   Returns id of code processing (pipelineId)
func (controller *playgroundController) RunCode(ctx context.Context, info *pb.RunCodeRequest) (*pb.RunCodeResponse, error) {
	// check for correct sdk
	switch info.Sdk {
	case pb.Sdk_SDK_UNSPECIFIED, pb.Sdk_SDK_GO, pb.Sdk_SDK_PYTHON, pb.Sdk_SDK_SCIO:
		logger.Errorf("RunCode(): unimplemented sdk: %s\n", info.Sdk)
		return nil, errors.InvalidArgumentError("Run code()", "unimplemented sdk: "+info.Sdk.String())
	}

	cacheExpirationTime := controller.env.ApplicationEnvs.CacheEnvs().KeyExpirationTime()
	pipelineId := uuid.New()

	lc, err := setupLifeCycle(info.Sdk, info.Code, pipelineId, controller.env.ApplicationEnvs.WorkingDir())
	if err != nil {
		return nil, errors.InternalError("Run code", "Error during setup file system: "+err.Error())
	}

	compileBuilder := setupCompileBuilder(lc, info.Sdk, controller.env.BeamSdkEnvs.ExecutorConfig)

	setToCache(ctx, controller.cacheService, pipelineId, cache.Status, pb.Status_STATUS_VALIDATING)
	if err := controller.cacheService.SetExpTime(ctx, pipelineId, cacheExpirationTime); err != nil {
		logger.Errorf("%s: RunCode(): cache.SetExpTime(): %s\n", pipelineId, err.Error())
		return nil, errors.InternalError("Run code()", "Error during set expiration to cache: "+err.Error())
	}

	// TODO change using of context.TODO() to context.Background()
	go processCode(context.TODO(), controller.cacheService, lc, compileBuilder, pipelineId, controller.env, info.Sdk)

	pipelineInfo := pb.RunCodeResponse{PipelineUuid: pipelineId.String()}
	return &pipelineInfo, nil
}

//CheckStatus is checking status for the specific pipeline by PipelineUuid
func (controller *playgroundController) CheckStatus(ctx context.Context, info *pb.CheckStatusRequest) (*pb.CheckStatusResponse, error) {
	pipelineId := info.PipelineUuid
	statusInterface, err := controller.cacheService.GetValue(ctx, uuid.MustParse(pipelineId), cache.Status)
	if err != nil {
		logger.Errorf("%s: CheckStatus(): cache.GetValue: error: %s", pipelineId, err.Error())
		return nil, errors.NotFoundError("CheckStatus", "Error during getting cache by pipelineId: "+pipelineId+", subKey: cache.SubKey_Status")
	}
	status, converted := statusInterface.(pb.Status)
	if !converted {
		return nil, errors.InternalError("CheckStatus", "status value from cache couldn't be converted to correct status enum")
	}
	return &pb.CheckStatusResponse{Status: status}, nil
}

//GetRunOutput is returning output of execution for specific pipeline by PipelineUuid
func (controller *playgroundController) GetRunOutput(ctx context.Context, info *pb.GetRunOutputRequest) (*pb.GetRunOutputResponse, error) {
	pipelineId := info.PipelineUuid
	runOutputInterface, err := controller.cacheService.GetValue(ctx, uuid.MustParse(pipelineId), cache.RunOutput)
	if err != nil {
		logger.Errorf("%s: GetRunOutput(): cache.GetValue: error: %s", pipelineId, err.Error())
		return nil, errors.NotFoundError("GetRunOutput", "there is no run output for pipelineId: "+pipelineId+", subKey: cache.SubKey_RunOutput")
	}
	runOutput, converted := runOutputInterface.(string)
	if !converted {
		return nil, errors.InternalError("GetRunOutput", "run output can't be converted to string")
	}
	pipelineResult := pb.GetRunOutputResponse{Output: runOutput}

	return &pipelineResult, nil
}

//GetRunError is returning error output of execution for specific pipeline by PipelineUuid
func (controller *playgroundController) GetRunError(ctx context.Context, info *pb.GetRunErrorRequest) (*pb.GetRunErrorResponse, error) {
	pipelineId := info.PipelineUuid
	runErrorInterface, err := controller.cacheService.GetValue(ctx, uuid.MustParse(pipelineId), cache.RunError)
	if err != nil {
		logger.Errorf("%s: GetRunError(): cache.GetValue: error: %s", pipelineId, err.Error())
		return nil, errors.NotFoundError("GetRunError", "there is no run error output for pipelineId: "+pipelineId+", subKey: cache.RunError")
	}
	runError, converted := runErrorInterface.(string)
	if !converted {
		return nil, errors.InternalError("GetRunError", "run output can't be converted to string")
	}
	pipelineResult := pb.GetRunErrorResponse{Output: runError}

	return &pipelineResult, nil
}

//GetCompileOutput is returning output of compilation for specific pipeline by PipelineUuid
func (controller *playgroundController) GetCompileOutput(ctx context.Context, info *pb.GetCompileOutputRequest) (*pb.GetCompileOutputResponse, error) {
	pipelineId := info.PipelineUuid
	compileOutputInterface, err := controller.cacheService.GetValue(ctx, uuid.MustParse(pipelineId), cache.CompileOutput)
	if err != nil {
		logger.Errorf("%s: GetCompileOutput(): cache.GetValue: error: %s", pipelineId, err.Error())
		return nil, errors.NotFoundError("GetCompileOutput", "there is no compile output for pipelineId: "+pipelineId+", subKey: cache.SubKey_CompileOutput")
	}
	compileOutput, converted := compileOutputInterface.(string)
	if !converted {
		return nil, errors.InternalError("GetCompileOutput", "compile output can't be converted to string")
	}
	pipelineResult := pb.GetCompileOutputResponse{Output: compileOutput}

	return &pipelineResult, nil
}

// Cancel is setting cancel flag to stop code processing
func (controller *playgroundController) Cancel(ctx context.Context, info *pb.CancelRequest) (*pb.CancelResponse, error) {
	pipelineId := info.PipelineUuid
	if err := setToCache(ctx, controller.cacheService, uuid.MustParse(pipelineId), cache.Canceled, true); err != nil {
		return nil, errors.InternalError("Cancel", "error during set cancel flag to cache")
	}
	return &pb.CancelResponse{}, nil
}

//GetListOfExamples returns the list of examples
func (controller *playgroundController) GetListOfExamples(ctx context.Context, info *pb.GetListOfExamplesRequest) (*pb.GetListOfExamplesResponse, error) {
	cd := storage.New()
	examples, err := cd.GetListOfExamples(ctx, info.Sdk, info.Category)
	if err != nil {
		logger.Errorf("%s: GetListOfExamples(): cloud storage error: %s", err.Error())
		return nil, errors.InternalError("GetListOfExamples(): ", err.Error())
	}
	response := pb.GetListOfExamplesResponse{SdkExamples: make([]*pb.Categories, 0)}
	for sdk, categories := range *examples {
		sdkCategories := pb.Categories{Sdk: pb.Sdk(pb.Sdk_value[sdk]), Categories: make([]*pb.Categories_Category, 0)}
		for categoryName, examplesArr := range categories {
			getCategoryWithExamples(categoryName, examplesArr, &sdkCategories)
		}
		response.SdkExamples = append(response.SdkExamples, &sdkCategories)
	}
	return &response, nil
}

func getCategoryWithExamples(categoryName string, examplesArr storage.ExamplesInfo, sdkCategories *pb.Categories) {
	category := pb.Categories_Category{
		CategoryName: categoryName,
		Examples:     make([]*pb.Example, 0),
	}
	for _, example := range examplesArr {
		category.Examples = append(category.Examples, &example)
	}
	sdkCategories.Categories = append(sdkCategories.Categories, &category)
}

// GetExample returns the code of the specific example
func (controller *playgroundController) GetExample(ctx context.Context, info *pb.GetExampleRequest) (*pb.GetExampleResponse, error) {
	cd := storage.New()
	codeString, err := cd.GetExample(ctx, info.GetCloudPath())
	if err != nil {
		logger.Errorf("%s: GetExample(): cloud storage error: %s", err.Error())
		return nil, errors.InternalError("GetListOfExamples(): ", err.Error())
	}
	response := pb.GetExampleResponse{Code: *codeString}
	return &response, nil
}

// GetExampleOutput returns the output of the compiled and run example
func (controller *playgroundController) GetExampleOutput(ctx context.Context, info *pb.GetExampleRequest) (*pb.GetRunOutputResponse, error) {
	cd := storage.New()
	output, err := cd.GetExampleOutput(ctx, info.GetCloudPath())
	if err != nil {
		logger.Errorf("%s: GetExampleOutput(): cloud storage error: %s", err.Error())
		return nil, errors.InternalError("GetExampleOutput(): ", err.Error())
	}
	response := pb.GetRunOutputResponse{Output: *output}
	return &response, nil
}

// setupLifeCycle creates fs_tool.LifeCycle and prepares files and folders needed to code processing
func setupLifeCycle(sdk pb.Sdk, code string, pipelineId uuid.UUID, workingDir string) (*fs_tool.LifeCycle, error) {
	// create file system service
	lc, err := fs_tool.NewLifeCycle(sdk, pipelineId, workingDir)
	if err != nil {
		logger.Errorf("%s: RunCode(): NewLifeCycle(): %s\n", pipelineId, err.Error())
		return nil, err
	}

	// create folders
	err = lc.CreateFolders()
	if err != nil {
		logger.Errorf("%s: RunCode(): CreateFolders(): %s\n", pipelineId, err.Error())
		return nil, err
	}

	// create file with code
	_, err = lc.CreateExecutableFile(code)
	if err != nil {
		logger.Errorf("%s: RunCode(): CreateExecutableFile(): %s\n", pipelineId, err.Error())
		return nil, err
	}
	return lc, nil
}

// setupCompileBuilder returns executors.CompileBuilder with validators and compiler based on sdk
func setupCompileBuilder(lc *fs_tool.LifeCycle, sdk pb.Sdk, executorConfig *environment.ExecutorConfig) *executors.CompileBuilder {
	filePath := lc.GetAbsoluteExecutableFilePath()
	val := setupValidators(sdk, filePath)

	compileBuilder := executors.NewExecutorBuilder().
		WithValidator().
		WithSdkValidators(val).
		WithCompiler()

	switch sdk {
	case pb.Sdk_SDK_JAVA:
		workingDir := lc.GetAbsoluteExecutableFilesFolderPath()

		compileBuilder = compileBuilder.
			WithCommand(executorConfig.CompileCmd).
			WithArgs(executorConfig.CompileArgs).
			WithFileName(filePath).
			WithWorkingDir(workingDir)
	}
	return compileBuilder
}

// setupRunBuilder returns executors.RunBuilder based on sdk
func setupRunBuilder(pipelineId uuid.UUID, lc *fs_tool.LifeCycle, sdk pb.Sdk, env *environment.Environment, compileBuilder *executors.CompileBuilder) (*executors.RunBuilder, error) {
	runBuilder := compileBuilder.
		WithRunner().
		WithCommand(env.BeamSdkEnvs.ExecutorConfig.RunCmd).
		WithArgs(env.BeamSdkEnvs.ExecutorConfig.RunArgs).
		WithWorkingDir(lc.GetAbsoluteExecutableFilesFolderPath())

	switch sdk {
	case pb.Sdk_SDK_JAVA:
		className, err := lc.ExecutableName(pipelineId, env.ApplicationEnvs.WorkingDir())
		if err != nil {
			logger.Errorf("%s: get executable file name: %s\n", pipelineId, err.Error())
			return nil, err
		}

		runBuilder = runBuilder.
			WithClassName(className)
	}
	return runBuilder, nil
}

// setupValidators returns slice of validators.Validator based on sdk
func setupValidators(sdk pb.Sdk, filepath string) *[]validators.Validator {
	var val *[]validators.Validator
	switch sdk {
	case pb.Sdk_SDK_JAVA:
		val = validators.GetJavaValidators(filepath)
	}
	return val
}

// processCode validates, compiles and runs code by pipelineId.
// During each operation updates status of execution and saves it into cache:
// - In case of processing works more that timeout duration saves playground.Status_STATUS_RUN_TIMEOUT as cache.Status into cache.
// - In case of code processing has been canceled saves playground.Status_STATUS_CANCELED as cache.Status into cache.
// - In case of validation step is failed saves playground.Status_STATUS_VALIDATION_ERROR as cache.Status into cache.
// - In case of compile step is failed saves playground.Status_STATUS_COMPILE_ERROR as cache.Status and compile logs as cache.CompileOutput into cache.
// - In case of compile step is completed with no errors saves compile output as cache.CompileOutput into cache.
// - In case of run step is failed saves playground.Status_STATUS_RUN_ERROR as cache.Status and run logs as cache.RunError into cache.
// - In case of run step is completed with no errors saves playground.Status_STATUS_FINISHED as cache.Status and run output as cache.RunOutput into cache.
// At the end of this method deletes all created folders.
func processCode(ctx context.Context, cacheService cache.Cache, lc *fs_tool.LifeCycle, compileBuilder *executors.CompileBuilder, pipelineId uuid.UUID, env *environment.Environment, sdk pb.Sdk) {
	ctxWithTimeout, cancelByTimeoutFunc := context.WithTimeout(ctx, env.ApplicationEnvs.PipelineExecuteTimeout())
	defer func(lc *fs_tool.LifeCycle) {
		cancelByTimeoutFunc()
		cleanUp(pipelineId, lc)
	}(lc)

	errorChannel := make(chan error, 1)
	dataChannel := make(chan interface{}, 1)
	successChannel := make(chan bool, 1)
	cancelChan := make(chan bool, 1)

	go cancelCheck(ctx, pipelineId, cancelChan, cacheService)

	// build executor for validate and compile steps
	exec := compileBuilder.Build()

	// validate
	logger.Infof("%s: Validate() ...\n", pipelineId)
	validateFunc := exec.Validate()
	go validateFunc(successChannel, errorChannel)

	if !processStep(ctxWithTimeout, pipelineId, cacheService, cancelChan, successChannel, nil, errorChannel, pb.Status_STATUS_VALIDATION_ERROR, pb.Status_STATUS_PREPARING) {
		return
	}

	// prepare
	logger.Info("%s: Prepare() ...\n", pipelineId)
	prepareFunc := exec.Prepare()
	go prepareFunc(successChannel, errorChannel)

	if !processStep(ctxWithTimeout, pipelineId, cacheService, cancelChan, successChannel, nil, errorChannel, pb.Status_STATUS_PREPARATION_ERROR, pb.Status_STATUS_COMPILING) {
		return
	}

	// compile
	logger.Infof("%s: Compile() ...\n", pipelineId)
	compileCmd := exec.Compile(ctxWithTimeout)
	go func(successCh chan bool, errCh chan error, dataCh chan interface{}) {
		// TODO separate stderr from stdout
		data, err := compileCmd.CombinedOutput()
		dataCh <- data
		if err != nil {
			errCh <- err
			successCh <- false
		} else {
			successCh <- true
		}
	}(successChannel, errorChannel, dataChannel)

	if !processStep(ctxWithTimeout, pipelineId, cacheService, cancelChan, successChannel, dataChannel, errorChannel, pb.Status_STATUS_COMPILE_ERROR, pb.Status_STATUS_EXECUTING) {
		return
	}

	runBuilder, err := setupRunBuilder(pipelineId, lc, sdk, env, compileBuilder)
	if err != nil {
		logger.Errorf("%s: error during setup runBuilder: %s\n", pipelineId, err.Error())
		setToCache(ctxWithTimeout, cacheService, pipelineId, cache.Status, pb.Status_STATUS_ERROR)
		return
	}

	// build executor for run step
	exec = runBuilder.Build()

	// run
	logger.Infof("%s: Run() ...\n", pipelineId)
	runCmd := exec.Run(ctxWithTimeout)
	go func(successCh chan bool, errCh chan error, dataCh chan interface{}) {
		// TODO separate stderr from stdout
		data, err := runCmd.CombinedOutput()
		dataCh <- data
		if err != nil {
			errCh <- err
			successChannel <- false
		} else {
			successChannel <- true
		}
	}(successChannel, errorChannel, dataChannel)

	processStep(ctxWithTimeout, pipelineId, cacheService, cancelChan, successChannel, dataChannel, errorChannel, pb.Status_STATUS_RUN_ERROR, pb.Status_STATUS_FINISHED)
}

// processStep processes each executor's step with cancel and timeout checks.
// If finishes by canceling, timeout or error - returns false.
// If finishes successfully returns true.
func processStep(ctx context.Context, pipelineId uuid.UUID, cacheService cache.Cache, cancelChan, successChan chan bool, dataChan chan interface{}, errorChannel chan error, errorCaseStatus, successCaseStatus pb.Status) bool {
	select {
	case <-ctx.Done():
		finishByContext(ctx, pipelineId, cacheService)
		return false
	case <-cancelChan:
		processCancel(ctx, cacheService, pipelineId)
		return false
	case ok := <-successChan:
		var data []byte = nil
		if dataChan != nil {
			temp := <-dataChan
			data = temp.([]byte)
		}
		if !ok {
			err := <-errorChannel
			processError(ctx, err, data, pipelineId, cacheService, errorCaseStatus)
			return false
		}
		processSuccess(ctx, data, pipelineId, cacheService, successCaseStatus)
	}
	return true
}

// finishByContext is used in case of runCode method finished by timeout
func finishByContext(ctx context.Context, pipelineId uuid.UUID, cacheService cache.Cache) {
	logger.Errorf("%s: processCode finish because of timeout\n", pipelineId)

	// set to cache pipelineId: cache.Canceled: false to stop cancelCheck() method
	setToCache(ctx, cacheService, pipelineId, cache.Canceled, false)

	// set to cache pipelineId: cache.SubKey_Status: Status_STATUS_RUN_TIMEOUT
	setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_RUN_TIMEOUT)
}

// cancelCheck checks cancel flag for code processing.
// If cancel flag doesn't exist in cache continue working.
// If cancel flag exists, and it is true it means that code processing was canceled. Set true to cancelChan and return.
// If cancel flag exists, and it is false it means that code processing was finished. Return.
func cancelCheck(ctx context.Context, pipelineId uuid.UUID, cancelChan chan bool, cacheService cache.Cache) {
	for {
		cancel, err := cacheService.GetValue(ctx, pipelineId, cache.Canceled)
		if err != nil {
			continue
		}
		if cancel.(bool) {
			cancelChan <- true
		}
		return
	}
}

// cleanUp removes all prepared folders for received LifeCycle
func cleanUp(pipelineId uuid.UUID, lc *fs_tool.LifeCycle) {
	logger.Infof("%s: DeleteFolders() ...\n", pipelineId)
	if err := lc.DeleteFolders(); err != nil {
		logger.Error("%s: DeleteFolders(): %s\n", pipelineId, err.Error())
	}
	logger.Infof("%s: DeleteFolders() complete\n", pipelineId)
	logger.Infof("%s: complete\n", pipelineId)
}

// processError processes error received during processing code via setting a corresponding status and output to cache
func processError(ctx context.Context, err error, data []byte, pipelineId uuid.UUID, cacheService cache.Cache, status pb.Status) {
	switch status {
	case pb.Status_STATUS_VALIDATION_ERROR:
		logger.Errorf("%s: Validate(): %s\n", pipelineId, err.Error())

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_VALIDATION_ERROR)
	case pb.Status_STATUS_PREPARATION_ERROR:
		logger.Errorf("%s: Prepare(): %s\n", pipelineId, err.Error())

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_PREPARATION_ERROR)
	case pb.Status_STATUS_COMPILE_ERROR:
		logger.Errorf("%s: Compile(): err: %s, output: %s\n", pipelineId, err.Error(), data)

		setToCache(ctx, cacheService, pipelineId, cache.CompileOutput, "error: "+err.Error()+", output: "+string(data))

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_COMPILE_ERROR)
	case pb.Status_STATUS_RUN_ERROR:
		logger.Errorf("%s: Run(): err: %s, output: %s\n", pipelineId, err.Error(), data)

		setToCache(ctx, cacheService, pipelineId, cache.RunError, "error: "+err.Error()+", output: "+string(data))

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_RUN_ERROR)
	}
	// set to cache pipelineId: cache.Canceled: false to stop cancelCheck() method
	setToCache(ctx, cacheService, pipelineId, cache.Canceled, false)
}

// processSuccess processes case after successful code processing via setting a corresponding status and output to cache
func processSuccess(ctx context.Context, output []byte, pipelineId uuid.UUID, cacheService cache.Cache, status pb.Status) {
	switch status {
	case pb.Status_STATUS_PREPARING:
		logger.Infof("%s: Validate() finish\n", pipelineId)

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_PREPARING)
	case pb.Status_STATUS_COMPILING:
		logger.Infof("%s: Prepare() finish\n", pipelineId)

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_COMPILING)
	case pb.Status_STATUS_EXECUTING:
		logger.Infof("%s: Compile() finish\n", pipelineId)

		setToCache(ctx, cacheService, pipelineId, cache.CompileOutput, string(output))

		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_EXECUTING)
	case pb.Status_STATUS_FINISHED:
		logger.Infof("%s: Run() finish\n", pipelineId)

		setToCache(ctx, cacheService, pipelineId, cache.RunOutput, string(output))

		// set to cache pipelineId: cache.Canceled: false to stop cancelCheck() method
		setToCache(ctx, cacheService, pipelineId, cache.Canceled, false)

		// set to cache pipelineId: cache.SubKey_Status: pb.Status_STATUS_FINISHED
		setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_FINISHED)
	}
}

// processCancel process case when code processing was canceled
func processCancel(ctx context.Context, cacheService cache.Cache, pipelineId uuid.UUID) {
	logger.Infof("%s: was canceled\n", pipelineId)

	// set to cache pipelineId: cache.SubKey_Status: pb.Status_STATUS_CANCELED
	setToCache(ctx, cacheService, pipelineId, cache.Status, pb.Status_STATUS_CANCELED)
}

// setToCache puts value to cache by key and subKey
func setToCache(ctx context.Context, cacheService cache.Cache, key uuid.UUID, subKey cache.SubKey, value interface{}) error {
	err := cacheService.SetValue(ctx, key, subKey, value)
	if err != nil {
		logger.Errorf("%s: cache.SetValue: %s\n", key, err.Error())
	}
	return err
}
