// Mocks generated by Mockito 5.2.0 from annotations
// in playground_components/test/src/common/example_cache.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:ui' as _i10;

import 'package:mockito/mockito.dart' as _i1;
import 'package:playground_components/src/cache/example_cache.dart' as _i4;
import 'package:playground_components/src/models/category_with_examples.dart'
    as _i6;
import 'package:playground_components/src/models/example.dart' as _i3;
import 'package:playground_components/src/models/example_base.dart' as _i2;
import 'package:playground_components/src/models/loading_status.dart' as _i8;
import 'package:playground_components/src/models/sdk.dart' as _i5;
import 'package:playground_components/src/repositories/models/shared_file.dart'
    as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeExampleBase_0 extends _i1.Fake implements _i2.ExampleBase {}

class _FakeExample_1 extends _i1.Fake implements _i3.Example {}

/// A class which mocks [ExampleCache].
///
/// See the documentation for Mockito's code generation for more information.
class MockExampleCache extends _i1.Mock implements _i4.ExampleCache {
  MockExampleCache() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<_i5.Sdk, List<_i6.CategoryWithExamples>> get categoryListsBySdk =>
      (super.noSuchMethod(
        Invocation.getter(#categoryListsBySdk),
        returnValue: <_i5.Sdk, List<_i6.CategoryWithExamples>>{},
      ) as Map<_i5.Sdk, List<_i6.CategoryWithExamples>>);
  @override
  Map<_i5.Sdk, _i3.Example> get defaultExamplesBySdk => (super.noSuchMethod(
        Invocation.getter(#defaultExamplesBySdk),
        returnValue: <_i5.Sdk, _i3.Example>{},
      ) as Map<_i5.Sdk, _i3.Example>);
  @override
  bool get isSelectorOpened => (super.noSuchMethod(
        Invocation.getter(#isSelectorOpened),
        returnValue: false,
      ) as bool);
  @override
  set isSelectorOpened(bool? _isSelectorOpened) => super.noSuchMethod(
        Invocation.setter(
          #isSelectorOpened,
          _isSelectorOpened,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i7.Future<void> get allExamplesFuture => (super.noSuchMethod(
        Invocation.getter(#allExamplesFuture),
        returnValue: Future<void>.value(),
      ) as _i7.Future<void>);
  @override
  _i8.LoadingStatus get catalogStatus => (super.noSuchMethod(
        Invocation.getter(#catalogStatus),
        returnValue: _i8.LoadingStatus.loading,
      ) as _i8.LoadingStatus);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  _i7.Future<void> loadAllPrecompiledObjectsIfNot() => (super.noSuchMethod(
        Invocation.method(
          #loadAllPrecompiledObjectsIfNot,
          [],
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as _i7.Future<void>);
  @override
  List<_i6.CategoryWithExamples> getCategories(_i5.Sdk? sdk) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCategories,
          [sdk],
        ),
        returnValue: <_i6.CategoryWithExamples>[],
      ) as List<_i6.CategoryWithExamples>);
  @override
  _i7.Future<_i2.ExampleBase> getPrecompiledObject(
    String? path,
    _i5.Sdk? sdk,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPrecompiledObject,
          [
            path,
            sdk,
          ],
        ),
        returnValue: Future<_i2.ExampleBase>.value(_FakeExampleBase_0()),
      ) as _i7.Future<_i2.ExampleBase>);
  @override
  _i7.Future<_i3.Example> loadSharedExample(String? id) => (super.noSuchMethod(
        Invocation.method(
          #loadSharedExample,
          [id],
        ),
        returnValue: Future<_i3.Example>.value(_FakeExample_1()),
      ) as _i7.Future<_i3.Example>);
  @override
  _i7.Future<String> saveSnippet({
    List<_i9.SharedFile>? files,
    _i5.Sdk? sdk,
    String? pipelineOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #saveSnippet,
          [],
          {
            #files: files,
            #sdk: sdk,
            #pipelineOptions: pipelineOptions,
          },
        ),
        returnValue: Future<String>.value(''),
      ) as _i7.Future<String>);
  @override
  _i7.Future<_i3.Example> loadExampleInfo(_i2.ExampleBase? example) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadExampleInfo,
          [example],
        ),
        returnValue: Future<_i3.Example>.value(_FakeExample_1()),
      ) as _i7.Future<_i3.Example>);
  @override
  void changeSelectorVisibility() => super.noSuchMethod(
        Invocation.method(
          #changeSelectorVisibility,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i7.Future<void> loadDefaultPrecompiledObjects() => (super.noSuchMethod(
        Invocation.method(
          #loadDefaultPrecompiledObjects,
          [],
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as _i7.Future<void>);
  @override
  _i7.Future<void> loadDefaultPrecompiledObjectsIfNot() => (super.noSuchMethod(
        Invocation.method(
          #loadDefaultPrecompiledObjectsIfNot,
          [],
        ),
        returnValue: Future<void>.value(),
        returnValueForMissingStub: Future<void>.value(),
      ) as _i7.Future<void>);
  @override
  _i7.Future<_i2.ExampleBase?> getCatalogExampleByPath(String? path) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCatalogExampleByPath,
          [path],
        ),
        returnValue: Future<_i2.ExampleBase?>.value(),
      ) as _i7.Future<_i2.ExampleBase?>);
  @override
  void addListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}