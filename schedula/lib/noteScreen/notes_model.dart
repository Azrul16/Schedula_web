class ClassNotes {
  ClassNotes({
    required this.courseTitle,
    required this.courseTecher,
    required this.downloadURL,
    required this.docID,
    required this.creatorId,
    required this.creatorIsCaptain,
    required this.semester,
    this.createdAt,
  });

  final String courseTitle;
  final String downloadURL;
  final String courseTecher;
  final String docID;
  final String creatorId;        // Store creator's ID
  final bool creatorIsCaptain;   // Store if creator is captain
  final String semester;         // Store semester for filtering
  final DateTime? createdAt;     // Store creation timestamp

  // Convert a ClassNotes instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'courseTitle': courseTitle,
      'downloadURL': downloadURL,
      'courseTecher': courseTecher,
      'creator_id': creatorId,
      'creator_is_captain': creatorIsCaptain,
      'semester': semester,
      'created_at': createdAt ?? DateTime.now(),
    };
  }

  // Create a ClassNotes instance from a JSON map.
  factory ClassNotes.fromJSON(Map<String, dynamic> json, String id) {
    return ClassNotes(
      courseTitle: json['courseTitle'],
      docID: id,
      downloadURL: json['downloadURL'],
      courseTecher: json['courseTecher'],
      creatorId: json['creator_id'] ?? '',
      creatorIsCaptain: json['creator_is_captain'] ?? false,
      semester: json['semester'] ?? '',
      createdAt: json['created_at']?.toDate(),
    );
  }
}
