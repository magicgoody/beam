/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * License); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

description = "Apache Beam :: Playground"

// generate protobuf client and server stubs
task("generateProto") {
  group = "build"
  doLast {
    exec {
      executable("buf")
      args("generate")
    }
  }
}
// lint proto files
task("lintProto") {
  group = "build"
  doLast {
    exec {
      executable("buf")
      args("lint", "--path", "api/")
    }
  }
}

// local deployment playground application - up
task("dockerComposeLocalUp") {
    dependsOn(":playground:backend:containers:router:docker", ":playground:frontend:docker", ":playground:backend:containers:go:docker", ":playground:backend:containers:java:docker", ":playground:backend:containers:python:docker", ":playground:backend:containers:scio:docker")
    group = "build"
    doLast {
        exec {
            executable("docker-compose")
            args("-f", "docker-compose.local.yml", "up", "-d")
        }
    }
}

// local deployment playground application - down
task("dockerComposeLocalDown") {
    group = "build"
    doLast {
        exec {
            executable("docker-compose")
            args("-f", "docker-compose.local.yml", "down")
        }
    }
}
