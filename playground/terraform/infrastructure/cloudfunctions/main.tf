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

resource "google_cloudfunctions_function" "playground_function_cleanup" {
  name        = "playground-function-cleanup"
  description = "Playground function cleanup"
  runtime     = "go120"
  entry_point = "cleanupSnippets"
  source_archive_bucket = var.gkebucket
  source_archive_object = "cloudfunction.zip"
  trigger_http = true

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
  }

  timeout = "540"
  available_memory_mb = 2048
  service_account_email = var.service_account_email_cf
}

resource "google_cloudfunctions_function_iam_member" "invoker_cleanup" {
  project        = google_cloudfunctions_function.playground_function_cleanup.project
  region         = google_cloudfunctions_function.playground_function_cleanup.region
  cloud_function = google_cloudfunctions_function.playground_function_cleanup.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function" "playground_function_delete" {
  name        = "playground-function-delete"
  description = "Playground function delete"
  runtime     = "go120"
  entry_point = "deleteObsoleteSnippets"
  source_archive_bucket = var.gkebucket
  source_archive_object = "cloudfunction.zip"
  trigger_http = true

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
  }

  timeout = "540"
  available_memory_mb = 2048
  service_account_email = var.service_account_email_cf
}

resource "google_cloudfunctions_function_iam_member" "invoker_delete" {
  project        = google_cloudfunctions_function.playground_function_delete.project
  region         = google_cloudfunctions_function.playground_function_delete.region
  cloud_function = google_cloudfunctions_function.playground_function_delete.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function" "playground_function_view" {
  name        = "playground-function-view"
  description = "Playground function view"
  runtime     = "go120"
  entry_point = "incrementSnippetViews"
  source_archive_bucket = var.gkebucket
  source_archive_object = "cloudfunction.zip"
  trigger_http = true

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
  }

  timeout = "540"
  available_memory_mb = 2048
  service_account_email = var.service_account_email_cf
}

resource "google_cloudfunctions_function_iam_member" "invoker_view" {
  project        = google_cloudfunctions_function.playground_function_view.project
  region         = google_cloudfunctions_function.playground_function_view.region
  cloud_function = google_cloudfunctions_function.playground_function_view.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}