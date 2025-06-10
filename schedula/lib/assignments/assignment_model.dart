import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String assignmentName;
  final String courseTitle;
  final String teacherName;
  final String lastDate;
  final String semester;
  final List<String> completedBy;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.assignmentName,
    required this.courseTitle,
    required this.teacherName,
    required this.lastDate,
    required this.semester,
    required this.completedBy,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json, String id) {
    return Assignment(
      id: id,
      assignmentName: json['assignmentName'] ?? '',
      courseTitle: json['courseTitle'] ?? '',
      teacherName: json['teacherName'] ?? '',
      lastDate: json['lastDate'] ?? '',
      semester: json['semester'] ?? '',
      completedBy: List<String>.from(json['completedBy'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentName': assignmentName,
      'courseTitle': courseTitle,
      'teacherName': teacherName,
      'lastDate': lastDate,
      'semester': semester,
      'completedBy': completedBy,
      'createdAt': createdAt,
    };
  }
}
