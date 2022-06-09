/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.beam.sdk.io.cdap;

import io.cdap.cdap.api.annotation.Description;
import io.cdap.cdap.api.annotation.Name;
import io.cdap.cdap.api.annotation.Plugin;
import io.cdap.cdap.api.data.batch.Output;
import io.cdap.cdap.api.data.format.StructuredRecord;
import io.cdap.cdap.api.dataset.lib.KeyValue;
import io.cdap.cdap.etl.api.Emitter;
import io.cdap.cdap.etl.api.FailureCollector;
import io.cdap.cdap.etl.api.PipelineConfigurer;
import io.cdap.cdap.etl.api.batch.BatchSink;
import io.cdap.cdap.etl.api.batch.BatchSinkContext;

/** Imitation of CDAP {@link BatchSink} plugin. Used to test {@link CdapIO#write()}. */
@Plugin(type = BatchSink.PLUGIN_TYPE)
@Name(EmployeeBatchSink.NAME)
@Description("Sink plugin to  put data to HubSpot CRM.")
public class EmployeeBatchSink extends BatchSink<StructuredRecord, String, String> {

  private final EmployeeConfig config;

  public static final String NAME = "EmployeeSink";

  public EmployeeBatchSink(EmployeeConfig config) {
    this.config = config;
  }

  @Override
  public void configurePipeline(PipelineConfigurer pipelineConfigurer) {
    super.configurePipeline(pipelineConfigurer);
    FailureCollector collector = pipelineConfigurer.getStageConfigurer().getFailureCollector();
    config.validate(collector);
  }

  @Override
  public void prepareRun(BatchSinkContext context) {
    FailureCollector collector = context.getFailureCollector();
    config.validate(collector);
    collector.getOrThrowException();
    context.addOutput(Output.of(config.referenceName, new EmployeeOutputFormatProvider(config)));
  }

  @Override
  public void transform(StructuredRecord input, Emitter<KeyValue<String, String>> emitter)
      throws Exception {
    emitter.emit(new KeyValue<>(input.get("id"), input.get("name")));
  }
}
