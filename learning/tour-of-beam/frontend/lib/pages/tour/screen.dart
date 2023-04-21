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

import 'package:flutter/material.dart';
import 'package:playground_components/playground_components.dart';

import '../../components/scaffold.dart';
import '../../constants/sizes.dart';
import '../../shortcuts/shortcuts_manager.dart';
import 'state.dart';
import 'widgets/content_tree.dart';
import 'widgets/playground.dart';
import 'widgets/unit_content.dart';

class TourScreen extends StatelessWidget {
  final TourNotifier tourNotifier;

  const TourScreen(this.tourNotifier);

  @override
  Widget build(BuildContext context) {
    return TobShortcutsManager(
      tourNotifier: tourNotifier,
      child: TobScaffold(
        playgroundController: tourNotifier.playgroundController,
        child: MediaQuery.of(context).size.width > ScreenBreakpoints.twoColumns
            ? _WideTour(tourNotifier)
            : _NarrowTour(tourNotifier),
      ),
    );
  }
}

class _WideTour extends StatelessWidget {
  final TourNotifier tourNotifier;

  const _WideTour(this.tourNotifier);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContentTreeWidget(controller: tourNotifier.contentTreeController),
        Expanded(
          child: SplitView(
            direction: Axis.horizontal,
            first: UnitContentWidget(tourNotifier),
            second: PlaygroundWidget(
              tourNotifier: tourNotifier,
            ),
          ),
        ),
      ],
    );
  }
}

class _NarrowTour extends StatelessWidget {
  final TourNotifier tourNotifier;

  const _NarrowTour(this.tourNotifier);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContentTreeWidget(controller: tourNotifier.contentTreeController),
              Expanded(child: UnitContentWidget(tourNotifier)),
            ],
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: const _NarrowScreenPlayground(),
          ),
        ],
      ),
    );
  }
}

class _NarrowScreenPlayground extends StatelessWidget {
  const _NarrowScreenPlayground();

  @override
  Widget build(BuildContext context) {
    // TODO(alexeyinkin): Even this way the narrow layout breaks, https://github.com/apache/beam/issues/23244
    return const Center(child: Text('TODO: Playground for narrow screen'));
  }
}
