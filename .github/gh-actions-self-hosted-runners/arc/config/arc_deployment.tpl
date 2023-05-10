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
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: main-runners
spec:
  template:
    spec:
      image: summerwind/actions-runner:v2.304.0-ubuntu-20.04-30355f7
      repository: ${repository}
      group: "Beam"
      labels:
        - "ubuntu-20.04"
        - "self-hosted"
      env: []
      resources:
        limits:
          cpu: "4.0"
          memory: "8Gi"
        requests:
          cpu: "500m"
          memory: "500Mi"
