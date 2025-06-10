import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ClassSchedule {
  ClassSchedule({
    required this.courseTitle,
    required this.courseTecher,
    required this.time,
    required this.courseCode,
    required this.docID,
    required this.semester,
    required this.creatorId,
    required this.creatorIsCaptain,
  });

  final String courseTitle;
  final String courseCode;
  final String courseTecher;
  final DateTime time;
  final String docID;
  final String semester;      // Store semester for filtering
  final String creatorId;     // Store creator's ID
  final bool creatorIsCaptain; // Store if creator is captain

  factory ClassSchedule.fromJSON(Map<String, dynamic> json, String id) {
    return ClassSchedule(
      docID: id,
      courseTitle: json['course_title'],
      courseTecher: json['course_teacher'],
      time: (json['time'] as Timestamp).toDate(),
      courseCode: json['course_code'],
      semester: json['semester'] ?? '',
      creatorId: json['creator_id'] ?? '',
      creatorIsCaptain: json['creator_is_captain'] ?? false,
    );
  }

  toJSON() {
    return {
      'course_title': courseTitle,
      'course_teacher': courseTecher,
      'time': time,
      'course_code': courseCode,
      'semester': semester,
      'creator_id': creatorId,
      'creator_is_captain': creatorIsCaptain,
    };
  }
}
