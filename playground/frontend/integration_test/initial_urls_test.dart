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

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:integration_test/integration_test.dart';
import 'package:playground_components/playground_components.dart';
import 'package:playground_components_dev/playground_components_dev.dart';

import 'common/common.dart';

// This test loads the app with most of the startup URL combinations.
// They cannot be tested directly due to a Flutter bug:
//     https://github.com/flutter/flutter/issues/118028
// So the test performs in-app navigation to these URLs.
// Many state objects are re-created this way, but not all,
// so the test is not clean.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Initial URLs', (WidgetTester wt) async {
    await init(wt);

    await _testEmbeddedRoot(wt);
    await _testStandaloneRoot(wt);

    await _testEmbeddedSdkOnly(wt);
    await _testStandaloneSdkOnly(wt);

    await _testCatalogDefaultExampleLoader(wt);
    await _testContentExampleLoader(wt);
    await _testEmptyExampleLoader(wt);
    await _testHttpExampleLoader(wt);
    await _testStandardExampleLoader(wt);
    await _testUserSharedExampleLoader(wt);

    await _testMultipleExamples(wt);
  });
}

const _embeddedPath = '/embedded';
const _standalonePath = '/';
const _paths = [_embeddedPath, _standalonePath];

const _fullViewOptionsMap = {
  'readonly': 'readonly1,readonly2',
  'unfold': 'unfold1,unfold2',
};
final _croppedViewOptionsMap = {
  ..._fullViewOptionsMap,
  'show': 'show',
};

final _fullViewOptions = _mapToQueryString(_fullViewOptionsMap);
final _croppedViewOptions = _mapToQueryString(_croppedViewOptionsMap);

Future<void> _testEmbeddedRoot(WidgetTester wt) async {
  await wt.navigateAndSettle(
    Uri.parse(_embeddedPath),
  );
  _expectSdk(wt, Sdk.java);
  _expectText(wt, '');
}

Future<void> _testStandaloneRoot(WidgetTester wt) async {
  final visibleText = await Examples.getVisibleTextByPath(
    MinimalWordCountJava.path,
    java,
  );

  await wt.navigateAndSettle(
    Uri.parse(_standalonePath),
  );
  _expectSdk(wt, Sdk.java);
  _expectText(wt, visibleText);
}

Future<void> _testEmbeddedSdkOnly(WidgetTester wt) async {
  await wt.navigateAndSettle(
    Uri.parse('$_embeddedPath?sdk=go'),
  );
  _expectSdk(wt, Sdk.go);
  _expectText(wt, '');
}

Future<void> _testStandaloneSdkOnly(WidgetTester wt) async {
  final visibleText = await Examples.getVisibleTextByPath(
    MinimalWordCountGo.path,
    go,
  );

  await wt.navigateAndSettle(
    Uri.parse('$_standalonePath?sdk=go'),
  );
  _expectSdk(wt, Sdk.go);
  _expectText(wt, visibleText);
}

Future<void> _testCatalogDefaultExampleLoader(WidgetTester wt) async {
  final visibleText = await Examples.getVisibleTextByPath(
    MinimalWordCountGo.path,
    go,
  );

  await wt.navigateAndSettle(
    Uri.parse('$_standalonePath?sdk=go&default=true'),
  );
  _expectSdk(wt, Sdk.go);
  _expectText(wt, visibleText);
}

Future<void> _testContentExampleLoader(WidgetTester wt) async {
  final content = await Examples.getFullTextByPath(ExampleGo.path);

  for (final path in _paths) {
    final files = jsonEncode([
      {'content': content, 'isMain': true}
    ]);
    await wt.navigateAndSettle(
      Uri.parse(
        '$path?sdk=go&files=${Uri.encodeComponent(files)}&$_fullViewOptions',
      ),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, ExampleGo.fullVisibleText);
    await _expectEditableAndReadOnly(wt);

    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&url=${ExampleGo.url}&$_croppedViewOptions'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, ExampleGo.croppedVisibleText);
    _expectReadOnly(wt);
  }
}

Future<void> _testEmptyExampleLoader(WidgetTester wt) async {
  for (final path in _paths) {
    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&empty=true'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, '');
  }
}

Future<void> _testHttpExampleLoader(WidgetTester wt) async {
  for (final path in _paths) {
    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&url=${ExampleGo.url}&$_fullViewOptions'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, ExampleGo.fullVisibleText);
    await _expectEditableAndReadOnly(wt);

    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&url=${ExampleGo.url}&$_croppedViewOptions'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, ExampleGo.croppedVisibleText);
    _expectReadOnly(wt);
  }
}

Future<void> _testStandardExampleLoader(WidgetTester wt) async {
  final visibleText = await Examples.getVisibleTextByPath(
    WordCountGo.path,
    go,
  );

  for (final path in _paths) {
    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&path=${WordCountGo.dbPath}'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, visibleText);
  }
}

Future<void> _testUserSharedExampleLoader(WidgetTester wt) async {
  final template = await Examples.getFullTextByPath(ExampleGo.path);
  final tail = '\n//${DateTime.now().millisecondsSinceEpoch}';
  final content = '$template$tail';

  final exampleCache = wt.findPlaygroundController().exampleCache;
  final snippetId = await exampleCache.saveSnippet(
    files: [SnippetFile(content: content, isMain: false, name: 'name')],
    sdk: Sdk.go,
    pipelineOptions: 'a=b',
  );

  print('Created user-shared example ID: $snippetId');

  for (final path in _paths) {
    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&shared=$snippetId&$_fullViewOptions'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, '${ExampleGo.fullVisibleText}$tail');
    await _expectEditableAndReadOnly(wt);

    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&url=${ExampleGo.url}&$_croppedViewOptions'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, ExampleGo.croppedVisibleText);
    _expectReadOnly(wt);
  }
}

Future<void> _testMultipleExamples(WidgetTester wt) async {
  final javaVisibleText = await Examples.getVisibleTextByPath(
    AggregationMaxJava.path,
    java,
  );
  const goVisibleText = ExampleGo.fullVisibleText;

  final examplesList = [
    {
      'sdk': Sdk.java.id,
      'path': AggregationMaxJava.dbPath,
      ..._fullViewOptionsMap,
    },
    {
      'sdk': Sdk.go.id,
      'url': ExampleGo.url,
      ..._fullViewOptionsMap,
    },
  ];
  final examples = jsonEncode(examplesList);

  for (final path in _paths) {
    await wt.navigateAndSettle(
      Uri.parse('$path?sdk=go&examples=$examples'),
    );
    _expectSdk(wt, Sdk.go);
    _expectText(wt, goVisibleText);
    await _expectEditableAndReadOnly(wt);

    final playgroundController = wt.findPlaygroundController();
    playgroundController.setSdk(Sdk.java);
    await wt.pumpAndSettle();

    _expectSdk(wt, Sdk.java);
    _expectText(wt, javaVisibleText);
  }
}

void _expectSdk(WidgetTester wt, Sdk sdk) {
  final controller = wt.findPlaygroundController();
  expect(controller.sdk, sdk);
}

void _expectText(WidgetTester wt, String visibleText) {
  final controller = wt.findOneCodeController();
  expect(controller.text, visibleText);
}

/// Checks that the example contains:
/// - at least two 'editable' substrings, and they are editable,
/// - at least two 'readonly' substrings, and they are read-only.
Future<void> _expectEditableAndReadOnly(WidgetTester wt) async {
  final controller = wt.findOneCodeController();

  for (int i = 0; i < 2; i++) {
    controller.value = controller.value.select('editable')!;

    final edited = controller.value.typed('');
    controller.value = edited;
    await wt.pumpAndSettle();
    expect(controller.value, edited, reason: 'Cannot edit an editable line');

    controller.value = controller.value.select('readonly')!.typed('');
    await wt.pumpAndSettle();
    expect(controller.value, edited, reason: 'Can edit a read-only line');
  }
}

/// Checks that every character in the editor is read-only.
void _expectReadOnly(WidgetTester wt) {
  final controller = wt.findOneCodeController();
  final value = controller.value;
  final text = controller.text;

  for (int i = text.length; --i >= 0;) {
    controller.value = value
        .copyWith(selection: TextSelection.collapsed(offset: i))
        .typed('a');
    expect(controller.value, value, reason: 'Can edit a read-only controller');
  }
}

String _mapToQueryString(Map<String, String> map) {
  return [for (final e in map.entries) '${e.key}=${e.value}'].join('&');
}
