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

"""Unit tests for counters and counter names."""

# pytype: skip-file

import unittest

from parameterized import parameterized_class

from apache_beam.utils import counters
from apache_beam.utils.counters import CounterName


class CounterNameTest(unittest.TestCase):
  def test_name_string_representation(self):
    counter_name = CounterName('counter_name', 'stage_name', 'step_name')

    # This string representation is utilized by the worker to report progress.
    # Change only if the worker code has also been changed.
    self.assertEqual('stage_name-step_name-counter_name', str(counter_name))
    self.assertIn(
        '<CounterName<stage_name-step_name-counter_name> at 0x',
        repr(counter_name))

  def test_equal_objects(self):
    self.assertEqual(
        CounterName('counter_name', 'stage_name', 'step_name'),
        CounterName('counter_name', 'stage_name', 'step_name'))
    self.assertNotEqual(
        CounterName('counter_name', 'stage_name', 'step_name'),
        CounterName('counter_name', 'stage_name', 'step_nam'))

    # Testing objects with an IOTarget.
    self.assertEqual(
        CounterName(
            'counter_name',
            'stage_name',
            'step_name',
            io_target=counters.side_input_id(1, 's9')),
        CounterName(
            'counter_name',
            'stage_name',
            'step_name',
            io_target=counters.side_input_id(1, 's9')))
    self.assertNotEqual(
        CounterName(
            'counter_name',
            'stage_name',
            'step_name',
            io_target=counters.side_input_id(1, 's')),
        CounterName(
            'counter_name',
            'stage_name',
            'step_name',
            io_target=counters.side_input_id(1, 's9')))

  def test_hash_two_objects(self):
    self.assertEqual(
        hash(CounterName('counter_name', 'stage_name', 'step_name')),
        hash(CounterName('counter_name', 'stage_name', 'step_name')))
    self.assertNotEqual(
        hash(CounterName('counter_name', 'stage_name', 'step_name')),
        hash(CounterName('counter_name', 'stage_name', 'step_nam')))


class CounterTest(unittest.TestCase):
  def setUp(self):
    self.counter_factory = counters.CounterFactory()

  def test_sum_counter(self):
    sum_counter = self.counter_factory.get_counter(
        CounterName('sum', 'stage_foo', 'step_bar'), counters.Counter.SUM)
    for i in range(100):
      sum_counter.update(i)

    self.assertEqual(99 * 50, sum_counter.value())

  def test_mean_counter(self):
    mean_counter = self.counter_factory.get_counter(
        CounterName('mean', 'stage_foo', 'step_bar'), counters.Counter.MEAN)
    for i in range(100):
      mean_counter.update(i)

    self.assertEqual(49, mean_counter.value())

  def test_distribution_counter(self):
    distribution_counter = self.counter_factory.get_counter(
        CounterName('distribution', 'stage_foo', 'step_bar'),
        counters.Counter.BEAM_DISTRIBUTION)
    for i in range(100):
      distribution_counter.update(i)

    self.assertEqual((49, 4950, 100, 0, 99), distribution_counter.value())


@parameterized_class([
    {
        'combiner': counters.Counter.SUM
    },
    {
        'combiner': counters.Counter.MEAN
    },
    {
        'combiner': counters.Counter.BEAM_DISTRIBUTION
    },
    {
        'combiner': counters.Counter.DATAFLOW_DISTRIBUTION
    },
])
class GeneralCounterTest(unittest.TestCase):
  def setUp(self):
    self.counter_factory = counters.CounterFactory()

  def test_reset(self):
    counter = self.counter_factory.get_counter(
        CounterName(self.combiner.default_label, 'stage_foo', 'reset'),
        self.combiner)

    for value in range(100):
      counter.update(value)
    expected = counter.value()
    counter.reset()

    for value in range(100):
      counter.update(value)

    self.assertEqual(expected, counter.value())

  def test_update_n(self):
    counter = self.counter_factory.get_counter(
        CounterName(self.combiner.default_label, 'stage_foo', 'update_n'),
        self.combiner)
    for i in range(100):
      value = i
      n = 100 - i
      for _ in range(n):
        counter.update(value)

    expected = counter.value()

    counter.reset()

    for i in range(100):
      value = i
      n = 100 - i
      counter.update_n(value, n)

    self.assertEqual(expected, counter.value())


if __name__ == '__main__':
  unittest.main()
