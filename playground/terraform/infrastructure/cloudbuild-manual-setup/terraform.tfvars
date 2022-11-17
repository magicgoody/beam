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

project                       = "sandbox-playground-001"                # Your Project ID
region                        = "us-central1"                           # Your GCP region name where resources will be provisioned
cloudbuild_service_account_id = "new-terraform-cloudbuild"              # The Name of SA to be used by Cloud Build to deploy Playground
cloudbuild_logs_bucket_name   = "cb-logs-bucket"                        # The name of GCP bucket for Cloud Build logs
github_repository_name        = "beam"                                  # The name of the GitHub repo. Example: In https://github.com/example/foo is 'foo'
github_repository_owner       = "akvelon"                               # Owner of the GitHub repo. Example: In https://github.com/example/foo is 'example'.
github_repository_branch      = "cloudbuild+manualsetup+playground"     # The name of GitHub repo branch