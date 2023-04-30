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

resource "google_cloudbuild_trigger" "tourofbeam_backend_infrastructure" {
  name     = "Tourofbeam-backend-infra-trigger"

  description = "Trigger used to deploy Tour of Beam Backend infrastructure"

  source_to_build {
    uri       = var.trigger_source_repo
    ref       = "refs/heads/master"
    repo_type = "GITHUB"
  }

  build {
    timeout = "3600s"
    options {
      machine_type = var.cloudbuild_machine_type
      logging = "CLOUD_LOGGING_ONLY"
    }

    step {
      id = "run_terraform"
      script = file("./cloudbuild_tourofbeam_infra.sh")
      name = "ubuntu"
      env = local.cloudbuild_init_environment
        }
  }

  substitutions = {
    _TF_VERSION : var.tf_version
    _PG_REGION : var.pg_region
    _PG_GKE_ZONE : var.pg_gke_zone
    _PG_GKE_NAME : var.pg_gke_name
    _STATE_BUCKET : var.state_bucket
    _ENV_NAME : var.env_name
    _TOB_REGION : var.tob_region
    _PG_DATASTORE_NAMESPACE: var.pg_datastore_namespace
    _REPO_NAME : var.trigger_source_repo
    _MACHINE_TYPE: var.machine_type
  }

  service_account = data.google_service_account.playground_infra_deploy_sa.id
}