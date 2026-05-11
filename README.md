# Schedula Web

A Flutter/Firebase academic scheduling platform for students and administrators. The app includes authentication, semester-based class/notes/assignment management, file upload/download utilities, push notifications, and an AI chat module backed by Google Generative AI.

## Features

- Firebase Authentication login/signup flow.
- Email verification workflow.
- Firestore-backed users, semesters, classes, notes, and assignments.
- Admin dashboard for semester management.
- Student-facing class, note, and assignment screens.
- Firebase Cloud Messaging and local notification handling.
- File picking, Firebase Storage integration, and file download support.
- Course data utilities for semester-wise academic content.
- Google Generative AI chat controller.
- SSLCommerz/WebView-related dependencies prepared for payment/web flows.

## Tech Stack

- Flutter
- Dart
- Firebase Core, Auth, Firestore, Storage, and Messaging
- Google Generative AI
- Provider
- Dio and HTTP
- Flutter Local Notifications
- Flutter Dotenv

## Project Structure

```text
schedula/
|-- lib/
|   |-- main.dart
|   |-- adminScreen/
|   |-- chatAI/
|   |-- classScreen/
|   |-- userAccounts/
|   `-- utils/
|-- assets/
|-- .env
`-- pubspec.yaml
```

## Getting Started

```bash
cd schedula
flutter pub get
flutter run
```

## Configuration

Before running in a new environment:

- Configure Firebase for your own project using FlutterFire.
- Add required keys to `.env`.
- Enable the Firebase products used by the app.
- Review Firestore security rules for student/admin access.
- Configure Android/iOS notification permissions and FCM setup.

## Notes

The repository includes generated Firebase options and environment files. Treat real API keys and service configuration carefully before publishing or deploying.
