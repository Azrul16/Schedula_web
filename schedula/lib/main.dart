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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> initializeFirebaseMessaging() async {
  // Only setup Firebase Messaging if supported
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Initialize flutter_local_notifications
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    await messaging.subscribeToTopic('general');
    print('Subscribed to general topic');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await messaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received a message while in the foreground!');
      print('Message data: \\${message.data}');
      if (message.notification != null) {
        print(
            'Message also contained a notification: \\${message.notification}');
        // Show notification using flutter_local_notifications
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null) {
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'fcm_default_channel',
                'FCM Notifications',
                channelDescription: 'Channel for FCM notifications',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  } else {
    print(
        "Firebase Messaging is not supported on this platform. Skipping setup.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Initializing Firebase...");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized.");

  await initializeFirebaseMessaging(); // Safe call

  await dotenv.load(fileName: ".env");

  InitializeController().init();

  // Create a GlobalKey for navigator to use in permission dialogs
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => FutureBuilder<Map<Permission, bool>>(
          future: PermissionHandler.requestAppPermissions(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              print('Error requesting permissions: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Log permission statuses
              snapshot.data!.forEach((permission, isGranted) {
                print(
                    'Permission ${permission.toString()}: ${isGranted ? 'Granted' : 'Denied'}');
              });
            }

            return const AuthGate();
          },
        ),
      ),
    ),
  );
}
