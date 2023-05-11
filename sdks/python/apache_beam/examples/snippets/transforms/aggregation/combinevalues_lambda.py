# coding=utf-8
#
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
#

# pytype: skip-file

# beam-playground:
#   name: CombineValuesLambda
#   description: Demonstration of CombineValue transform usage with a lambda function.
#   multifile: false
#   default_example: false
#   context_line: 37
#   categories:
#     - Core Transforms
#   complexity: BASIC
#   tags:
#     - transforms
#     - pairs
#     - combine

def combinevalues_lambda(test=None):
  # [START combinevalues_lambda]
  import apache_beam as beam

  with beam.Pipeline() as pipeline:
    saturated_total = (
        pipeline
        | 'Create plant counts' >> beam.Create([
            ('🥕', [3, 2]),
            ('🍆', [1]),
            ('🍅', [4, 5, 3]),
        ])
        | 'Saturated sum' >>
        beam.CombineValues(lambda values: min(sum(values), 8))
        | beam.Map(print))
    # [END combinevalues_lambda]
    if test:
      test(saturated_total)


if __name__ == '__main__':
  combinevalues_lambda()
