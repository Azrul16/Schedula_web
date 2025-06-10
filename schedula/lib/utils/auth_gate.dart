import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schedula/userAccounts/login_page.dart';
import 'package:schedula/classScreen/start_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Login();
        }
        return const StartScreen();
      },
    );
  }
}

Future<String?> checkUserAuthAndGetSemester() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String? semester = userData['semister'];

        if (semester != null) {
          print(semester);
          return semester;
        } else {
          print("Semester field is missing in user's document.");
          return null;
        }
      } else {
        print("User document does not exist.");
        return null;
      }
    } else {
      print("User is not logged in.");
      return null;
    }
  } catch (e) {
    print("Error: $e");
    return null;
  }
}

class GlobalUtils {
  static Future<String?> getCurrentUserId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      return user?.uid;
    } catch (e) {
      print("Error getting user ID: $e");
      return null;
    }
  }

  static Future<String?> getCurrentUserSemester() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;
          return userData['semister'];
        }
      }
      return null;
    } catch (e) {
      print("Error getting semester: $e");
      return null;
    }
  }

  static Future<bool> isCaptain() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          var userData = userDoc.data() as Map<String, dynamic>;
          return userData['isCaptain'] ?? false;
        }
      }
      return false;
    } catch (e) {
      print("Error checking captain status: $e");
      return false;
    }
  }

  static Future<bool> isAdmin() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        if (user.email == "azrul@gmail.com") {
          print("User's email matches: ${user.email}");
          return true;
        } else {
          print("User's email does not match: ${user.email}");
          return false;
        }
      } else {
        print("User is not logged in or email is null.");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
