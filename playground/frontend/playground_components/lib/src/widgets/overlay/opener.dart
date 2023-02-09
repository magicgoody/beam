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

import '../../controllers/public_notifier.dart';
import 'widget.dart';

void openOverlay({
  required BuildContext context,
  required PublicNotifier closeNotifier,
  required Positioned positioned,
  bool isDismissible = true,
}) {
  final overlay = OverlayEntry(
    builder: (context) {
      return BeamOverlay(
        close: closeNotifier.notifyPublic,
        isDismissible: isDismissible,
        child: positioned,
      );
    },
  );
  closeNotifier.addListener(overlay.remove);
  Overlay.of(context)?.insert(overlay);
}
