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
package org.apache.beam.examples.complete.cdap.options;

import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.Validation;

public interface CdapSalesforceSinkOptions extends CdapSalesforceOptions {

  @Validation.Required
  @Description(
      "Strategy used to handle erroneous records.\n"
          + "SKIP - Ignores erroneous records.\n"
          + "STOP - Fails pipeline due to erroneous record.")
  String getErrorHandling();

  void setErrorHandling(String errorHandling);

  @Validation.Required
  @Description(
      "Maximum size in bytes of a batch of records when writing to Salesforce. "
          + "This value cannot be greater than 10,000,000.")
  String getMaxBytesPerBatch();

  void setMaxBytesPerBatch(String maxBytesPerBatch);

  @Validation.Required
  @Description(
      "Maximum number of records to include in a batch when writing to Salesforce."
          + "This value cannot be greater than 10,000.")
  String getMaxRecordsPerBatch();

  void setMaxRecordsPerBatch(String maxRecordsPerBatch);

  @Validation.Required
  @Description(
      "Operation used for sinking data into Salesforce.\n"
          + "Insert - adds records.\n"
          + "Upsert - upserts the records. Salesforce will decide if sObjects "
          + "are the same using external id field.\n"
          + "Update - updates existing records based on Id field.")
  String getOperation();

  void setOperation(String operation);

  @Validation.Required
  @Description("Salesforce object name to insert records into.")
  String getsObject();

  void setsObject(String sObject);

  @Description("Locks directory path where locks will be stored.")
  String getLocksDirPath();

  void setLocksDirPath(String locksDirPath);
}
