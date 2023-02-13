#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


openssl x509 -in /home/appuser/.mitmproxy/mitmproxy-ca.pem -inform PEM -out /usr/local/share/ca-certificates/extra/mitmproxy-ca.crt
update-ca-certificates
cat /home/appuser/.mitmproxy/mitmproxy-ca.pem >> /usr/local/lib/python3.7/site-packages/certifi/cacert.pem
export http_proxy=http://$PLAYGROUND_MITM_SERVICE_HOST:$PLAYGROUND_MITM_SERVICE_PORT
export https_proxy=http://$PLAYGROUND_MITM_SERVICE_HOST:$PLAYGROUND_MITM_SERVICE_PORT
su appuser -c /opt/playground/backend/server_python_backend
