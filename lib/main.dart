// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:r_tasks/auth_service.dart';
import 'firebase_options.dart';


Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //final auth = FirebaseAuth.instanceFor(app: Firebase.app(), persistence: Persistence.NONE);
  //await FirebaseAuth.instance.useAuthEmulator('localhost', 57387);
  //await auth.setPersistence(Persistence.LOCAL);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to RM Tasks',
      home: AuthService().handleAuthState(),
    );
  }
}