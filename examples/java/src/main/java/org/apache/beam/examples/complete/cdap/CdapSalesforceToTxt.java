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
package org.apache.beam.examples.complete.cdap;

import io.cdap.cdap.api.data.schema.Schema;
import java.util.LinkedHashMap;
import java.util.Map;
import org.apache.beam.examples.complete.cdap.options.CdapSalesforceOptions;
import org.apache.beam.examples.complete.cdap.transforms.FormatInputTransform;
import org.apache.beam.examples.complete.cdap.utils.PluginConfigOptionsConverter;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.PipelineResult;
import org.apache.beam.sdk.coders.KvCoder;
import org.apache.beam.sdk.coders.SerializableCoder;
import org.apache.beam.sdk.coders.StringUtf8Coder;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.MapValues;
import org.apache.beam.sdk.transforms.Values;
import org.apache.beam.sdk.values.TypeDescriptors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@SuppressWarnings("rawtypes")
public class CdapSalesforceToTxt {

  /* Logger for class.*/
  private static final Logger LOG = LoggerFactory.getLogger(CdapSalesforceToTxt.class);

  /**
   * Main entry point for pipeline execution.
   *
   * @param args Command line arguments to the pipeline.
   */
  public static void main(String[] args) {
    CdapSalesforceOptions options =
        PipelineOptionsFactory.fromArgs(args).withValidation().as(CdapSalesforceOptions.class);

    // Create the pipeline
    Pipeline pipeline = Pipeline.create(options);
    run(pipeline, options);
  }

  /**
   * Runs a pipeline which reads records from CDAP Salesforce plugin.
   *
   * @param options arguments to the pipeline
   */
  public static PipelineResult run(Pipeline pipeline, CdapSalesforceOptions options) {
    Map<String, Object> paramsMap =
        PluginConfigOptionsConverter.salesforceOptionsToParamsMap(options);
    LOG.info("Starting Cdap-Salesforce pipeline with parameters: {}", paramsMap);

    /*
     * Steps:
     *  1) Read messages from Cdap Salesforce
     *  2) Extract values only
     *  3) Write successful records to .txt file
     */

    pipeline
        .apply("readFromCdapSalesforce", FormatInputTransform.readFromCdapSalesforce(paramsMap))
        .setCoder(
            KvCoder.of(
                SerializableCoder.of(Schema.class), SerializableCoder.of(LinkedHashMap.class)))
        .apply(MapValues.into(TypeDescriptors.strings()).via(LinkedHashMap::toString))
        .setCoder(KvCoder.of(SerializableCoder.of(Schema.class), StringUtf8Coder.of()))
        .apply(Values.create())
        .apply("writeToTxt", TextIO.write().to(options.getOutputTxtFilePath()));

    return pipeline.run();
  }
}
