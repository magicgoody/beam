// Mocks generated by Mockito 5.3.2 from annotations
// in playground_components/test/src/controllers/example_loaders/examples_loader_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i15;
import 'dart:ui' as _i17;

import 'package:mockito/mockito.dart' as _i1;
import 'package:playground_components/src/cache/example_cache.dart' as _i2;
import 'package:playground_components/src/controllers/code_runner.dart' as _i5;
import 'package:playground_components/src/controllers/example_loaders/examples_loader.dart'
    as _i3;
import 'package:playground_components/src/controllers/output_filter_type_controller.dart'
    as _i4;
import 'package:playground_components/src/controllers/playground_controller.dart'
    as _i13;
import 'package:playground_components/src/controllers/snippet_editing_controller.dart'
    as _i8;
import 'package:playground_components/src/models/category_with_examples.dart'
    as _i18;
import 'package:playground_components/src/models/event_snippet_context.dart'
    as _i7;
import 'package:playground_components/src/models/example.dart' as _i12;
import 'package:playground_components/src/models/example_base.dart' as _i11;
import 'package:playground_components/src/models/example_loading_descriptors/example_loading_descriptor.dart'
    as _i16;
import 'package:playground_components/src/models/example_loading_descriptors/examples_loading_descriptor.dart'
    as _i10;
import 'package:playground_components/src/models/example_loading_descriptors/user_shared_example_loading_descriptor.dart'
    as _i9;
import 'package:playground_components/src/models/example_view_options.dart'
    as _i20;
import 'package:playground_components/src/models/loading_status.dart' as _i19;
import 'package:playground_components/src/models/sdk.dart' as _i14;
import 'package:playground_components/src/models/shortcut.dart' as _i6;
import 'package:playground_components/src/models/snippet_file.dart' as _i21;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeExampleCache_0 extends _i1.SmartFake implements _i2.ExampleCache {
  _FakeExampleCache_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExamplesLoader_1 extends _i1.SmartFake
    implements _i3.ExamplesLoader {
  _FakeExamplesLoader_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeOutputFilterTypeController_2 extends _i1.SmartFake
    implements _i4.OutputFilterTypeController {
  _FakeOutputFilterTypeController_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCodeRunner_3 extends _i1.SmartFake implements _i5.CodeRunner {
  _FakeCodeRunner_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBeamShortcut_4 extends _i1.SmartFake implements _i6.BeamShortcut {
  _FakeBeamShortcut_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEventSnippetContext_5 extends _i1.SmartFake
    implements _i7.EventSnippetContext {
  _FakeEventSnippetContext_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSnippetEditingController_6 extends _i1.SmartFake
    implements _i8.SnippetEditingController {
  _FakeSnippetEditingController_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserSharedExampleLoadingDescriptor_7 extends _i1.SmartFake
    implements _i9.UserSharedExampleLoadingDescriptor {
  _FakeUserSharedExampleLoadingDescriptor_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExamplesLoadingDescriptor_8 extends _i1.SmartFake
    implements _i10.ExamplesLoadingDescriptor {
  _FakeExamplesLoadingDescriptor_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExampleBase_9 extends _i1.SmartFake implements _i11.ExampleBase {
  _FakeExampleBase_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeExample_10 extends _i1.SmartFake implements _i12.Example {
  _FakeExample_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [PlaygroundController].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlaygroundController extends _i1.Mock
    implements _i13.PlaygroundController {
  MockPlaygroundController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.ExampleCache get exampleCache => (super.noSuchMethod(
        Invocation.getter(#exampleCache),
        returnValue: _FakeExampleCache_0(
          this,
          Invocation.getter(#exampleCache),
        ),
      ) as _i2.ExampleCache);
  @override
  _i3.ExamplesLoader get examplesLoader => (super.noSuchMethod(
        Invocation.getter(#examplesLoader),
        returnValue: _FakeExamplesLoader_1(
          this,
          Invocation.getter(#examplesLoader),
        ),
      ) as _i3.ExamplesLoader);
  @override
  _i4.OutputFilterTypeController get outputTypeController =>
      (super.noSuchMethod(
        Invocation.getter(#outputTypeController),
        returnValue: _FakeOutputFilterTypeController_2(
          this,
          Invocation.getter(#outputTypeController),
        ),
      ) as _i4.OutputFilterTypeController);
  @override
  _i5.CodeRunner get codeRunner => (super.noSuchMethod(
        Invocation.getter(#codeRunner),
        returnValue: _FakeCodeRunner_3(
          this,
          Invocation.getter(#codeRunner),
        ),
      ) as _i5.CodeRunner);
  @override
  set codeRunner(_i5.CodeRunner? _codeRunner) => super.noSuchMethod(
        Invocation.setter(
          #codeRunner,
          _codeRunner,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i6.BeamShortcut get runShortcut => (super.noSuchMethod(
        Invocation.getter(#runShortcut),
        returnValue: _FakeBeamShortcut_4(
          this,
          Invocation.getter(#runShortcut),
        ),
      ) as _i6.BeamShortcut);
  @override
  set runShortcut(_i6.BeamShortcut? _runShortcut) => super.noSuchMethod(
        Invocation.setter(
          #runShortcut,
          _runShortcut,
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i6.BeamShortcut get resetShortcut => (super.noSuchMethod(
        Invocation.getter(#resetShortcut),
        returnValue: _FakeBeamShortcut_4(
          this,
          Invocation.getter(#resetShortcut),
        ),
      ) as _i6.BeamShortcut);
  @override
  set resetShortcut(_i6.BeamShortcut? _resetShortcut) => super.noSuchMethod(
        Invocation.setter(
          #resetShortcut,
          _resetShortcut,
        ),
        returnValueForMissingStub: null,
      );
  @override
  String get examplesTitle => (super.noSuchMethod(
        Invocation.getter(#examplesTitle),
        returnValue: '',
      ) as String);
  @override
  _i7.EventSnippetContext get eventSnippetContext => (super.noSuchMethod(
        Invocation.getter(#eventSnippetContext),
        returnValue: _FakeEventSnippetContext_5(
          this,
          Invocation.getter(#eventSnippetContext),
        ),
      ) as _i7.EventSnippetContext);
  @override
  bool get graphAvailable => (super.noSuchMethod(
        Invocation.getter(#graphAvailable),
        returnValue: false,
      ) as bool);
  @override
  List<_i6.BeamShortcut> get shortcuts => (super.noSuchMethod(
        Invocation.getter(#shortcuts),
        returnValue: <_i6.BeamShortcut>[],
      ) as List<_i6.BeamShortcut>);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  _i8.SnippetEditingController requireSnippetEditingController() =>
      (super.noSuchMethod(
        Invocation.method(
          #requireSnippetEditingController,
          [],
        ),
        returnValue: _FakeSnippetEditingController_6(
          this,
          Invocation.method(
            #requireSnippetEditingController,
            [],
          ),
        ),
      ) as _i8.SnippetEditingController);
  @override
  void setEmptyIfNoSdk(_i14.Sdk? sdk) => super.noSuchMethod(
        Invocation.method(
          #setEmptyIfNoSdk,
          [sdk],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setEmptyIfNotExists(
    _i14.Sdk? sdk, {
    required bool? setCurrentSdk,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #setEmptyIfNotExists,
          [sdk],
          {#setCurrentSdk: setCurrentSdk},
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i15.Future<void> setExampleBase(_i11.ExampleBase? exampleBase) =>
      (super.noSuchMethod(
        Invocation.method(
          #setExampleBase,
          [exampleBase],
        ),
        returnValue: _i15.Future<void>.value(),
        returnValueForMissingStub: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  void setExample(
    _i12.Example? example, {
    required _i16.ExampleLoadingDescriptor? descriptor,
    required bool? setCurrentSdk,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #setExample,
          [example],
          {
            #descriptor: descriptor,
            #setCurrentSdk: setCurrentSdk,
          },
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setSdk(
    _i14.Sdk? sdk, {
    bool? notify = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #setSdk,
          [sdk],
          {#notify: notify},
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i15.Future<void> reset() => (super.noSuchMethod(
        Invocation.method(
          #reset,
          [],
        ),
        returnValue: _i15.Future<void>.value(),
        returnValueForMissingStub: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  void resetErrorMessageText() => super.noSuchMethod(
        Invocation.method(
          #resetErrorMessageText,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void setPipelineOptions(String? options) => super.noSuchMethod(
        Invocation.method(
          #setPipelineOptions,
          [options],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i15.Future<_i9.UserSharedExampleLoadingDescriptor> saveSnippet() =>
      (super.noSuchMethod(
        Invocation.method(
          #saveSnippet,
          [],
        ),
        returnValue: _i15.Future<_i9.UserSharedExampleLoadingDescriptor>.value(
            _FakeUserSharedExampleLoadingDescriptor_7(
          this,
          Invocation.method(
            #saveSnippet,
            [],
          ),
        )),
      ) as _i15.Future<_i9.UserSharedExampleLoadingDescriptor>);
  @override
  _i10.ExamplesLoadingDescriptor getLoadingDescriptor() => (super.noSuchMethod(
        Invocation.method(
          #getLoadingDescriptor,
          [],
        ),
        returnValue: _FakeExamplesLoadingDescriptor_8(
          this,
          Invocation.method(
            #getLoadingDescriptor,
            [],
          ),
        ),
      ) as _i10.ExamplesLoadingDescriptor);
  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void addListener(_i17.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(_i17.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
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

/// A class which mocks [ExampleCache].
///
/// See the documentation for Mockito's code generation for more information.
class MockExampleCache extends _i1.Mock implements _i2.ExampleCache {
  MockExampleCache() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<_i14.Sdk, List<_i18.CategoryWithExamples>> get categoryListsBySdk =>
      (super.noSuchMethod(
        Invocation.getter(#categoryListsBySdk),
        returnValue: <_i14.Sdk, List<_i18.CategoryWithExamples>>{},
      ) as Map<_i14.Sdk, List<_i18.CategoryWithExamples>>);
  @override
  Map<_i14.Sdk, _i12.Example> get defaultExamplesBySdk => (super.noSuchMethod(
        Invocation.getter(#defaultExamplesBySdk),
        returnValue: <_i14.Sdk, _i12.Example>{},
      ) as Map<_i14.Sdk, _i12.Example>);
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
  _i15.Future<void> get allExamplesFuture => (super.noSuchMethod(
        Invocation.getter(#allExamplesFuture),
        returnValue: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  _i19.LoadingStatus get catalogStatus => (super.noSuchMethod(
        Invocation.getter(#catalogStatus),
        returnValue: _i19.LoadingStatus.loading,
      ) as _i19.LoadingStatus);
  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);
  @override
  _i15.Future<void> loadAllPrecompiledObjectsIfNot() => (super.noSuchMethod(
        Invocation.method(
          #loadAllPrecompiledObjectsIfNot,
          [],
        ),
        returnValue: _i15.Future<void>.value(),
        returnValueForMissingStub: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  List<_i18.CategoryWithExamples> getCategories(_i14.Sdk? sdk) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCategories,
          [sdk],
        ),
        returnValue: <_i18.CategoryWithExamples>[],
      ) as List<_i18.CategoryWithExamples>);
  @override
  _i15.Future<_i11.ExampleBase> getPrecompiledObject(
    String? path,
    _i14.Sdk? sdk,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getPrecompiledObject,
          [
            path,
            sdk,
          ],
        ),
        returnValue: _i15.Future<_i11.ExampleBase>.value(_FakeExampleBase_9(
          this,
          Invocation.method(
            #getPrecompiledObject,
            [
              path,
              sdk,
            ],
          ),
        )),
      ) as _i15.Future<_i11.ExampleBase>);
  @override
  _i15.Future<_i12.Example> loadSharedExample(
    String? id, {
    required _i20.ExampleViewOptions? viewOptions,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadSharedExample,
          [id],
          {#viewOptions: viewOptions},
        ),
        returnValue: _i15.Future<_i12.Example>.value(_FakeExample_10(
          this,
          Invocation.method(
            #loadSharedExample,
            [id],
            {#viewOptions: viewOptions},
          ),
        )),
      ) as _i15.Future<_i12.Example>);
  @override
  _i15.Future<String> saveSnippet({
    required List<_i21.SnippetFile>? files,
    required _i14.Sdk? sdk,
    required String? pipelineOptions,
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
        returnValue: _i15.Future<String>.value(''),
      ) as _i15.Future<String>);
  @override
  _i15.Future<_i12.Example> loadExampleInfo(_i11.ExampleBase? example) =>
      (super.noSuchMethod(
        Invocation.method(
          #loadExampleInfo,
          [example],
        ),
        returnValue: _i15.Future<_i12.Example>.value(_FakeExample_10(
          this,
          Invocation.method(
            #loadExampleInfo,
            [example],
          ),
        )),
      ) as _i15.Future<_i12.Example>);
  @override
  void setSelectorOpened(bool? value) => super.noSuchMethod(
        Invocation.method(
          #setSelectorOpened,
          [value],
        ),
        returnValueForMissingStub: null,
      );
  @override
  _i15.Future<_i12.Example?> getDefaultExampleBySdk(_i14.Sdk? sdk) =>
      (super.noSuchMethod(
        Invocation.method(
          #getDefaultExampleBySdk,
          [sdk],
        ),
        returnValue: _i15.Future<_i12.Example?>.value(),
      ) as _i15.Future<_i12.Example?>);
  @override
  _i15.Future<void> loadDefaultPrecompiledObjects() => (super.noSuchMethod(
        Invocation.method(
          #loadDefaultPrecompiledObjects,
          [],
        ),
        returnValue: _i15.Future<void>.value(),
        returnValueForMissingStub: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  _i15.Future<void> loadDefaultPrecompiledObjectsIfNot() => (super.noSuchMethod(
        Invocation.method(
          #loadDefaultPrecompiledObjectsIfNot,
          [],
        ),
        returnValue: _i15.Future<void>.value(),
        returnValueForMissingStub: _i15.Future<void>.value(),
      ) as _i15.Future<void>);
  @override
  _i15.Future<_i11.ExampleBase?> getCatalogExampleByPath(String? path) =>
      (super.noSuchMethod(
        Invocation.method(
          #getCatalogExampleByPath,
          [path],
        ),
        returnValue: _i15.Future<_i11.ExampleBase?>.value(),
      ) as _i15.Future<_i11.ExampleBase?>);
  @override
  void addListener(_i17.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );
  @override
  void removeListener(_i17.VoidCallback? listener) => super.noSuchMethod(
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
