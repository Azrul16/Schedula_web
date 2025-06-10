import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:schedula/announsmentScreen/announce_model.dart';
import 'package:schedula/utils/permission_handler.dart';

class AnnouncementService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'announcements';

  // Create a new announcement
  static Future<String?> createAnnouncement({
    required String title,
    required String description,
    required String downloadURL,
    required String semester,
  }) async {
    try {
      // Check if user has permission to create announcements
      if (!await PermissionHandler.canCreateContent()) {
        throw Exception('User does not have permission to create announcements');
      }

      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = _firestore.collection(_collection).doc();
      
      final announcement = Announcements(
        title: title,
        description: description,
        downloadURL: downloadURL,
        docID: docRef.id,
        creatorId: user.uid,
        creatorIsCaptain: true, // Since we already checked permissions
        semester: semester,
        createdAt: DateTime.now(),
      );

      await docRef.set(announcement.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating announcement: $e');
      return null;
    }
  }

  // Get announcements for current user's semester
  static Stream<List<Announcements>> getAnnouncementsForCurrentSemester() async* {
    try {
      final semester = await PermissionHandler.getCurrentUserSemester();
      if (semester == null) {
        yield [];
        return;
      }

      yield* _firestore
          .collection(_collection)
          .where('semester', isEqualTo: semester)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Announcements.fromJSON(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error getting announcements: $e');
      yield [];
    }
  }

  // Get all announcements (for captains)
  static Stream<List<Announcements>> getAllAnnouncements() async* {
    try {
      if (!await PermissionHandler.isCurrentUserCaptain()) {
        yield [];
        return;
      }

      yield* _firestore
          .collection(_collection)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Announcements.fromJSON(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error getting all announcements: $e');
      yield [];
    }
  }

  // Update an announcement
  static Future<bool> updateAnnouncement({
    required String docId,
    required String title,
    required String description,
    required String downloadURL,
  }) async {
    try {
      if (!await PermissionHandler.canCreateContent()) {
        throw Exception('User does not have permission to update announcements');
      }

      await _firestore.collection(_collection).doc(docId).update({
        'title': title,
        'description': description,
        'downloadURL': downloadURL,
        'updated_at': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Error updating announcement: $e');
      return false;
    }
  }

  // Delete an announcement
  static Future<bool> deleteAnnouncement(String docId) async {
    try {
      if (!await PermissionHandler.canCreateContent()) {
        throw Exception('User does not have permission to delete announcements');
      }

      await _firestore.collection(_collection).doc(docId).delete();
      return true;
    } catch (e) {
      print('Error deleting announcement: $e');
      return false;
    }
  }
}
