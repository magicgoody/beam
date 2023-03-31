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

class EmergeOnHoverWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final double maxOpacity;
  final double minOpacity;

  const EmergeOnHoverWidget({
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.maxOpacity = 1.0,
    this.minOpacity = 0.4,
  }) : assert(
          minOpacity < maxOpacity,
          'minOpacity should be less than maxOpacity',
        );
  @override
  EmergeOnHoverWidgetState createState() => EmergeOnHoverWidgetState();
}

class EmergeOnHoverWidgetState extends State<EmergeOnHoverWidget> {
  double _opacity = 0.4;

  @override
  void initState() {
    super.initState();
    _opacity = widget.minOpacity;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _opacity = widget.maxOpacity),
      onExit: (_) => setState(() => _opacity = widget.minOpacity),
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: widget.animationDuration,
        child: widget.child,
      ),
    );
  }
}
