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
#   name: CoreTransformsSolution4
#   description: Core Transforms fourth motivating solution.
#   multifile: false
#   context_line: 30
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


class GroupWordsByFirstLetter(beam.CombineFn):
    def create_accumulator(self):
        return {}

    def add_input(self, accumulator, word):
        first_letter = word[0]
        if first_letter not in accumulator:
            accumulator[first_letter] = []
        accumulator[first_letter].append(word)
        return accumulator

    def merge_accumulators(self, accumulators):
        merged = {}
        for accumulator in accumulators:
            for letter, words in accumulator.items():
                if letter not in merged:
                    merged[letter] = []
                merged[letter] += words
        return merged

    def extract_output(self, accumulator):
        return accumulator



with beam.Pipeline() as p:
  parts = p | 'Log words' >> beam.io.ReadFromText('gs://apache-beam-samples/shakespeare/kinglear.txt') \
            | beam.combiners.Sample.FixedSizeGlobally(100) \
            | beam.FlatMap(lambda line: line) \
            | beam.FlatMap(lambda sentence: sentence.split()) \
            | beam.Filter(lambda word: not word.isspace() or word.isalnum()) \
            | beam.CombineGlobally(GroupWordsByFirstLetter()) \
            | Output()
