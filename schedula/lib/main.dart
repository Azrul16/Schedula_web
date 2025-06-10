import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schedula/chatAI/chat_controller.dart';
import 'package:schedula/firebase_options.dart';
import 'package:schedula/utils/auth_gate.dart';
import 'package:schedula/utils/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase initialized.");

  await dotenv.load(fileName: ".env");

  InitializeController().init();

  // Create a GlobalKey for navigator to use in permission dialogs
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder:
            (context) => FutureBuilder<Map<Permission, bool>>(
              future: PermissionHandler.requestAppPermissions(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  print('Error requesting permissions: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  // Log permission statuses
                  snapshot.data!.forEach((permission, isGranted) {
                    print(
                      'Permission ${permission.toString()}: ${isGranted ? 'Granted' : 'Denied'}',
                    );
                  });
                }

                return const AuthGate();
              },
            ),
      ),
    ),
  );
}
