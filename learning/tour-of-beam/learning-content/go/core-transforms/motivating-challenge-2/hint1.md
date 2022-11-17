<!--
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
You can solve the challenge with this way:
1. First you need to divide `PCollection` by `beam.ParDo(s, func(line string) (string,int){ .. .}`.
2. Combine by key the values should be combined `(score1 + score2)` `beam.CombinePerKey(s, func(score1, score2 int) int{ ... }`