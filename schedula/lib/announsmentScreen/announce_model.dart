class Announcements {
  Announcements({
    required this.title,
    required this.description,
    required this.downloadURL,
    required this.docID,
    required this.creatorId,
    required this.creatorIsCaptain,
    required this.semester,
    this.createdAt,
  });

  final String title;
  final String downloadURL;
  final String description;
  final String docID;
  final String creatorId;        // Store creator's ID
  final bool creatorIsCaptain;   // Store if creator is captain
  final String semester;         // Store semester for filtering
  final DateTime? createdAt;     // Store creation timestamp

  // Convert a Announcements instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'downloadURL': downloadURL,
      'description': description,
      'creator_id': creatorId,
      'creator_is_captain': creatorIsCaptain,
      'semester': semester,
      'created_at': createdAt ?? DateTime.now(),
    };
  }

  // Create a Announcements instance from a JSON map.
  factory Announcements.fromJSON(Map<String, dynamic> json, String id) {
    return Announcements(
      title: json['title'],
      downloadURL: json['downloadURL'],
      description: json['description'],
      docID: id,
      creatorId: json['creator_id'] ?? '',
      creatorIsCaptain: json['creator_is_captain'] ?? false,
      semester: json['semester'] ?? '',
      createdAt: json['created_at']?.toDate(),
    );
  }
}
