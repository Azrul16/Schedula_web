import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHandler {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Request all necessary app permissions
  static Future<Map<Permission, bool>> requestAppPermissions(BuildContext context) async {
    Map<Permission, bool> statuses = {};

    // List of permissions needed by the app
    final permissions = [
      Permission.notification,  // For push notifications
      Permission.storage,      // For file upload/download
      Permission.photos,       // For image picking
      Permission.camera,       // For taking photos
      Permission.microphone,   // For voice notes (if needed)
      Permission.mediaLibrary, // For media access
    ];

    // Request each permission
    for (var permission in permissions) {
      if (await permission.isDenied) {
        // Show rationale before requesting permission
        String rationale = _getPermissionRationale(permission);
        bool shouldRequest = await _showPermissionRationale(context, permission, rationale);
        
        if (shouldRequest) {
          final status = await permission.request();
          statuses[permission] = status.isGranted;
          
          // If permission is permanently denied, open app settings
          if (status.isPermanentlyDenied) {
            await _showSettingsDialog(context, permission);
          }
        } else {
          statuses[permission] = false;
        }
      } else {
        statuses[permission] = true;
      }
    }

    return statuses;
  }

  // Show permission rationale dialog
  static Future<bool> _showPermissionRationale(BuildContext context, Permission permission, String rationale) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(rationale),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Deny'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Allow'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show settings dialog when permission is permanently denied
  static Future<void> _showSettingsDialog(BuildContext context, Permission permission) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'This feature requires ${_getPermissionName(permission)}. Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Get permission rationale message
  static String _getPermissionRationale(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return 'Notifications are needed to keep you updated about new assignments, notes, and class schedules.';
      case Permission.storage:
        return 'Storage access is needed to upload and download files like notes and assignments.';
      case Permission.photos:
        return 'Photo access is needed to upload images for assignments and notes.';
      case Permission.camera:
        return 'Camera access is needed to take photos for assignments and notes.';
      case Permission.microphone:
        return 'Microphone access is needed for voice notes and audio recordings.';
      case Permission.mediaLibrary:
        return 'Media access is needed to upload media files for assignments and notes.';
      default:
        return 'This permission is required for app functionality.';
    }
  }

  // Get permission name
  static String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.notification:
        return 'notification access';
      case Permission.storage:
        return 'storage access';
      case Permission.photos:
        return 'photo access';
      case Permission.camera:
        return 'camera access';
      case Permission.microphone:
        return 'microphone access';
      case Permission.mediaLibrary:
        return 'media access';
      default:
        return 'permission';
    }
  }

  // Check if all required permissions are granted
  static Future<bool> checkPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.storage,
      Permission.photos,
      Permission.camera,
      Permission.microphone,
      Permission.mediaLibrary,
    ];

    for (var permission in permissions) {
      if (!(await permission.isGranted)) {
        return false;
      }
    }
    return true;
  }

  // Check specific permission status
  static Future<bool> checkSpecificPermission(Permission permission) async {
    return await permission.isGranted;
  }

  // Request specific permission with rationale
  static Future<bool> requestSpecificPermission(BuildContext context, Permission permission) async {
    if (await permission.isDenied) {
      String rationale = _getPermissionRationale(permission);
      bool shouldRequest = await _showPermissionRationale(context, permission, rationale);
      
      if (shouldRequest) {
        final status = await permission.request();
        if (status.isPermanentlyDenied) {
          await _showSettingsDialog(context, permission);
        }
        return status.isGranted;
      }
      return false;
    }
    return true;
  }

  // Check if current user is a captain
  static Future<bool> isCurrentUserCaptain() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data()?['isCaptain'] ?? false;
    } catch (e) {
      print('Error checking captain status: $e');
      return false;
    }
  }

  // Check if user has access to content based on semester
  static Future<bool> hasAccessToSemesterContent(String contentSemester) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data()?['semister'] == contentSemester;
    } catch (e) {
      print('Error checking semester access: $e');
      return false;
    }
  }

  // Check if user can create/edit content (must be captain)
  static Future<bool> canCreateContent() async {
    return await isCurrentUserCaptain();
  }

  // Check if user can view specific content
  static Future<bool> canViewContent(String contentSemester) async {
    final isCaptain = await isCurrentUserCaptain();
    final hasSemesterAccess = await hasAccessToSemesterContent(contentSemester);
    
    // Captains can view all content, others only their semester's content
    return isCaptain || hasSemesterAccess;
  }

  // Get current user's semester
  static Future<String?> getCurrentUserSemester() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      return userDoc.data()?['semister'];
    } catch (e) {
      print('Error getting user semester: $e');
      return null;
    }
  }

  // Get current user's ID
  static String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
