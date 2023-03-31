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
import 'package:flutter/services.dart';

import '../../playground_components.dart';
import 'emerge_on_hover.dart';

class CopyButton extends StatefulWidget {
  const CopyButton({
    required this.beforePressed,
    required this.text,
  });

  final VoidCallback beforePressed;
  final String text;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return EmergeOnHoverWidget(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            widget.beforePressed();
            await _copyText();
            setState(() {
              _isPressed = true;
            });
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
              _isPressed = false;
            });
            });
          },
          child: SizedBox.square(
            dimension: BeamIconSizes.medium,
            child: Center(
              child: _isPressed
                  ? const Icon(
                      Icons.check,
                      size: BeamIconSizes.medium,
                    )
                  : const Icon(
                      Icons.file_copy_outlined,
                      size: BeamIconSizes.small,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyText() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.text));
    } on Exception catch (ex) {
      print('Copy to clipboard failed: ${widget.text}'); // ignore: avoid_print
      print(ex); // ignore: avoid_print
    }
  }
}
