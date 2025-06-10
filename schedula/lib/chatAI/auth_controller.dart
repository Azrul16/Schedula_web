import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static Map<String, dynamic>? userData = {};

  loadUserData(String userID) async {
    final response =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    userData = response.data();
  }
}
