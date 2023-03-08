/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Mocks generated by Mockito 5.2.0 from annotations
// in playground/test/pages/playground/states/mocks/example_repository_mock.dart.
// Do not manually edit this file.

import 'dart:async' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:playground/modules/examples/models/category_model.dart' as _i7;
import 'package:playground/modules/examples/models/example_model.dart' as _i2;
import 'package:playground/modules/examples/repositories/example_repository.dart'
    as _i4;
import 'package:playground/modules/examples/repositories/models/get_example_request.dart'
    as _i9;
import 'package:playground/modules/examples/repositories/models/get_list_of_examples_request.dart'
    as _i8;
import 'package:playground/modules/examples/repositories/models/get_snippet_request.dart'
    as _i10;
import 'package:playground/modules/examples/repositories/models/get_snippet_response.dart'
    as _i3;
import 'package:playground/modules/examples/repositories/models/save_snippet_request.dart'
    as _i11;
import 'package:playground/modules/sdk/models/sdk.dart' as _i6;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeExampleModel_0 extends _i1.Fake implements _i2.ExampleModel {}

class _FakeGetSnippetResponse_1 extends _i1.Fake
    implements _i3.GetSnippetResponse {}

/// A class which mocks [ExampleRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockExampleRepository extends _i1.Mock implements _i4.ExampleRepository {
  MockExampleRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<Map<_i6.SDK, List<_i7.CategoryModel>>> getListOfExamples(
          _i8.GetListOfExamplesRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getListOfExamples, [request]),
              returnValue: Future<Map<_i6.SDK, List<_i7.CategoryModel>>>.value(
                  <_i6.SDK, List<_i7.CategoryModel>>{}))
          as _i5.Future<Map<_i6.SDK, List<_i7.CategoryModel>>>);
  @override
  _i5.Future<_i2.ExampleModel> getDefaultExample(
          _i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getDefaultExample, [request]),
              returnValue:
                  Future<_i2.ExampleModel>.value(_FakeExampleModel_0()))
          as _i5.Future<_i2.ExampleModel>);
  @override
  _i5.Future<String> getExampleSource(_i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getExampleSource, [request]),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
  @override
  _i5.Future<String> getExampleOutput(_i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getExampleOutput, [request]),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
  @override
  _i5.Future<String> getExampleLogs(_i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getExampleLogs, [request]),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
  @override
  _i5.Future<String> getExampleGraph(_i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getExampleGraph, [request]),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
  @override
  _i5.Future<_i2.ExampleModel> getExample(
          _i9.GetExampleRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getExample, [request]),
              returnValue:
                  Future<_i2.ExampleModel>.value(_FakeExampleModel_0()))
          as _i5.Future<_i2.ExampleModel>);
  @override
  _i5.Future<_i3.GetSnippetResponse> getSnippet(
          _i10.GetSnippetRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#getSnippet, [request]),
              returnValue: Future<_i3.GetSnippetResponse>.value(
                  _FakeGetSnippetResponse_1()))
          as _i5.Future<_i3.GetSnippetResponse>);
  @override
  _i5.Future<String> saveSnippet(_i11.SaveSnippetRequestWrapper? request) =>
      (super.noSuchMethod(Invocation.method(#saveSnippet, [request]),
          returnValue: Future<String>.value('')) as _i5.Future<String>);
}
