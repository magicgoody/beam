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

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:playground_components/playground_components.dart';

import '../repositories/client/client.dart';

class AuthNotifier extends ChangeNotifier {
  final TobClient client;

  AuthNotifier({required this.client}) {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  Future<String?> getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> logIn(AuthProvider authProvider) async {
    try {
      await FirebaseAuth.instance.signInWithPopup(authProvider);
    } on Exception catch (e) {
      PlaygroundComponents.toastNotifier.addException(e);
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      await client.postDeleteUserProgress();
      await FirebaseAuth.instance.currentUser?.delete();
    } on Exception catch (e) {
      PlaygroundComponents.toastNotifier.addException(e);
    }
  }
}
