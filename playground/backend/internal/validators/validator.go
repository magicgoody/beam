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

package validators

import (
	pb "beam.apache.org/playground/backend/internal/api/v1"
	"fmt"
)

const (
	UnitTestValidatorName = "UnitTest"
	KatasValidatorName    = "Katas"
)

type ValidationOutcome int

const (
	Unknown ValidationOutcome = iota
	Invalid
	Valid
	Error
)

type ValidationResult struct {
	IsUnitTest  ValidationOutcome
	IsKatas     ValidationOutcome
	IsValidPath ValidationOutcome
}

type Validator interface {
	Validate() (ValidationResult, error)
}

func GetValidator(sdk pb.Sdk, filepath string) (Validator, error) {
	switch sdk {
	case pb.Sdk_SDK_JAVA:
		return GetJavaValidator(filepath), nil
	case pb.Sdk_SDK_GO:
		return GetGoValidator(filepath), nil
	case pb.Sdk_SDK_PYTHON:
		return GetPythonValidator(filepath), nil
	case pb.Sdk_SDK_SCIO:
		return GetScioValidator(filepath), nil
	default:
		return nil, fmt.Errorf("incorrect sdk: %s", sdk)
	}
}

func resultFromBool(val bool) ValidationOutcome {
	if val {
		return Valid
	} else {
		return Invalid
	}
}

func (r ValidationOutcome) ToBool() (bool, error) {
	if r == Unknown {
		return false, fmt.Errorf("result is unknown")
	}
	if r == Error {
		return false, fmt.Errorf("result indicated error")
	}
	return r == Valid, nil
}
