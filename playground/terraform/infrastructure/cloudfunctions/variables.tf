#
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
#

variable "function_names" {
  type    = list(string)
  default = ["cleanupSnippets", "deleteObsoleteSnippets", "incrementSnippetViews"]
}

variable "function_description" {
  type    = string
  default = "Playground function"
}

variable "runtime" {
  type    = string
  default = "go120"
}

variable "source_archive_bucket" {
  type    = string
  default = var.gkebucket
}

variable "source_archive_object" {
  type    = string
  default = "cloudfunction.zip"
}

variable "timeout" {
  type    = string
  default = "540"
}

variable "available_memory_mb" {
  type    = number
  default = 2048
}

variable "service_account_email_cf" {
  type    = string
  default = var.service_account_email_cf
}

variable "project_id" {
  type    = string
}