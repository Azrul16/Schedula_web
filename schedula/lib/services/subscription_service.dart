// TODO Implement this library.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkSubscription(String userId) async {
    try {
      final doc =
          await _firestore.collection('subscriptions').doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final subscribedAt = data['subscribedAt'] as Timestamp;
      final expiryDate = subscribedAt.toDate().add(const Duration(days: 30));

      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> subscribeUser(String userId) async {
    await _firestore.collection('subscriptions').doc(userId).set({
      'subscribedAt': FieldValue.serverTimestamp(),
    });
  }
}
