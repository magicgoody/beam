#   Licensed to the Apache Software Foundation (ASF) under one
#   or more contributor license agreements.  See the NOTICE file
#   distributed with this work for additional information
#   regarding copyright ownership.  The ASF licenses this file
#   to you under the Apache License, Version 2.0 (the
#   "License"); you may not use this file except in compliance
#   with the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# beam-playground:
#   name: CoreTransformsChallenge4
#   description: Core Transforms fourth motivating challenge.
#   multifile: false
#   context_line: 23
#   categories:
#     - Quickstart
#   complexity: BASIC
#   tags:
#     - hellobeam

import apache_beam as beam

# Output PCollection
class Output(beam.PTransform):
    class _OutputFn(beam.DoFn):
        def __init__(self, prefix=''):
            super().__init__()
            self.prefix = prefix

        def process(self, element):
            print(self.prefix+str(element))

    def __init__(self, label=None,prefix=''):
        super().__init__(label)
        self.prefix = prefix

    def expand(self, input):
        input | beam.ParDo(self._OutputFn(self.prefix))

class Accum:
    current = [{}]

    def __init__(self):

class AverageFn(beam.CombineFn):

    def create_accumulator(self):
        return Accum()

    def add_input(self, accumulator, element):
        return word + element

    def merge_accumulators(self, accumulators):
        return sums

    def extract_output(self, accumulator):
        sum = accumulator
        return sum



with beam.Pipeline() as p:
  parts = p | 'Log words' >> beam.io.ReadFromText('gs://apache-beam-samples/shakespeare/kinglear.txt') \
            | beam.FlatMap(lambda sentence: sentence.split()) \
            | beam.Filter(lambda word: not word.isspace() or word.isalnum()) \
            | beam.CombineGlobally(AverageFn()) \
            | Output()