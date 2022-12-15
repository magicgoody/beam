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

apply(plugin = "org.apache.beam.module")
apply(plugin = "base")

val applyDockerNature: groovy.lang.Closure<*> by project;
applyDockerNature()

val playgroundJobServerProject = "${project.path.replace("-container", "")}"

description = "Apache Beam :: Playground :: Frontend"

val dockerDependency by configurations.creating

configurations {
  dockerDependency
}

dependencies {
  dockerDependency(project(path = playgroundJobServerProject, configuration = "shadow"))
}

tasks.register("generate") {
  dependsOn("playground_components:generate")

  dependsOn("generateCode")

  group = "build"
  description = "Generates all generated files."
}

tasks.register("printPath") {
  doLast {
    exec {
      executable("printenv")
      args("PATH")
    }
  }
}

tasks.register("analyze") {
  dependsOn("playground_components:generateCode")
  dependsOn("generateCode")

  group = "verification"
  description = "Analyze dart code"

  doLast {
    exec {
      // Exact paths instead of '.' so it does not go into playground_components
      executable("dart")
      args("analyze", "lib", "test")
    }
  }
}

tasks.register("pubGet") {
  group = "build"
  description = "Get packages for the playground frontend project"

  doLast {
    exec {
      executable("flutter")
      args("pub", "get")
    }
  }
}

tasks.register("format") {
  group = "build"
  description = "Idiomatically format Dart source code"

  doLast {
    exec {
      // Exact paths instead of '.' so it does not go into playground_components
      executable("dart")
      args("format", "lib", "test")
    }
  }
}

tasks.register("run") {
  group = "application"
  description = "Run application on Google Chrome"

  doLast {
    exec {
      executable("flutter")
      args("run", "-d", "chrome")
    }
  }
}

tasks.register("test") {
  dependsOn("playground_components:generateCode")
  dependsOn("generateCode")

  group = "verification"
  description = "flutter test"

  doLast {
    exec {
      executable("flutter")
      args("test")
    }
  }
}

tasks.register("precommit") {
  dependsOn("playground_components:precommit")

  dependsOn("analyze")
  dependsOn("test")
}

tasks.register("generateCode") {
  dependsOn("playground_components:generateCode")

  dependsOn("cleanFlutter")
  dependsOn("pubGet")

  group = "build"
  description = "Generate code"

  doLast {
    exec {
      executable("flutter")
      args("pub", "run", "build_runner", "build", "--delete-conflicting-outputs")
    }
  }
}

tasks.register("cleanFlutter") {
  group = "build"
  description = "Remove build artifacts"

  doLast {
    exec {
      executable("flutter")
      args("clean")
    }
  }
}

tasks.register("cleanGenerated") {
  dependsOn("playground_components:cleanGenerated")

  group = "build"
  description = "Remove build artifacts"

  doLast {
    println("Deleting:")

    deleteFilesByRegExp(".*\\.g\\.dart\$")
    deleteFilesByRegExp(".*\\.gen\\.dart\$")
    deleteFilesByRegExp(".*\\.mocks\\.dart\$")
  }
}

val deleteFilesByRegExp by extra(
  fun(re: String) {
    // Prints file names.
    exec {
      executable("find")
      args("assets", "lib", "test", "-regex", re)
    }

    // Actually deletes them.
    exec {
      executable("find")
      args("assets", "lib", "test", "-regex", re, "-delete")
    }
  }
)

tasks.register<Copy>("copyDockerfileDependencies") {
   group = "build"
   description = "Copy files that required to build docker container"

   copy {
      from(".")
      into("build/")
      exclude("build")
      exclude("Dockerfile")
   }
   copy {
      from("../playground")
      into("build/playground")
   }
}

val docker: com.palantir.gradle.docker.DockerExtension by project
print(docker)

docker {
  val docker_image_default_repo_prefix: String by project
  val containerImageName: groovy.lang.Closure<*> by project

  group = "build"
  description = "Build container for playground frontend application"
  name = containerImageName(
          name = docker_image_default_repo_prefix + "playground-frontend",
          root = if (project.rootProject.hasProperty(["docker-repository-root"]))
                  project.rootProject["docker-repository-root"] else
                  project.docker_image_default_repo_root
  )

  files = "./build/"
  tags = containerImageTags()
}

// Ensure that we build the required resources and copy and file dependencies from related projects
val dockerPrepare: DefaultTask by project
dockerPrepare.dependsOn("copyDockerfileDependencies")
