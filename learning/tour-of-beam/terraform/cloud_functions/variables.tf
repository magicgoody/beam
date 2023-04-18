# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# This will be used to generate certain variables values
resource "random_string" "id" {
  length = 4
  upper = false
  special = false
}

# This will be used to generate certain variables
variable "resource_name_prefix" {
  type = string
  description = "The resource name prefix applied to all resource naming for the application"
  default = "tour-of-beam"
}

# Taken from output of SETUP module
variable "service_account_id" {
  description = "The name of Service Account to run Cloud Function"
}

# Required for environment variables inside of cloud functions
# Generated by command (gcloud config get-value project) in Kotlin Gradle script
variable "project_id" {
  description = "The GCP Project ID of function"
}

variable "region" {
  description = "The GCP Region where cloud functions will be created"
}

# Taken from output of FUNCTIONS_BUCKETS module
variable "source_archive_bucket" {
  description = "The GCS bucket containing the zip archive which contains the function"
}

# Taken from output of FUNCTIONS_BUCKETS module
variable "source_archive_object" {
  description = "The source archive object (file) in archive bucket"
}

# Constant. Will be served as cloud functions URLs/endpoints
variable "entry_point_names" {
  type = list
  default = ["getSdkList", "getContentTree", "getUnitContent", "getUserProgress", "postUnitComplete", "postUserCode", "postDeleteProgress"]
}

# Generated during execution Kotlin Gradle script
variable "pg_router_host" {
  description = "Hostname:port of Playground GKE cluster's router grpc workload"
}

# To be provided manually as argument for Kotlin Gradle script
variable "environment" {
  description = "The name of the environment for deployment of cloud functions. Will be appended to the name of cloud functions"
}
