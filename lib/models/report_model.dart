class Report {

  final String reportId;
  final String reporterUid;
  final String title;
  final String category;
  final String tag;
  final DateTime dateTime;
  final String location;
  final String description;
  final String status;
  final String? assignedCounsellorUid;
  final DateTime createdAt;
  final List<Map<String, dynamic>> attachments;

  Report({
    required this.reportId,
    required this.reporterUid,
    required this.title,
    required this.category,
    required this.tag,
    required this.dateTime,
    required this.location,
    required this.description,
    required this.status,
    this.assignedCounsellorUid,
    required this.createdAt,
    required this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      "reporterUid": reporterUid,
      "title": title,
      "category": category,
      "tag": tag,
      "dateTime": dateTime,
      "location": location,
      "description": description,
      "status": status,
      "assignedCounsellorUid": assignedCounsellorUid,
      "createdAt": createdAt,
      "attachments": attachments,
    };
  }

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseFirestoreDate(dynamic value) {
      if (value == null) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }

      if (value is DateTime) {
        return value;
      }

      try {
        return value.toDate();
      } catch (_) {
        if (value is String) {
          return DateTime.tryParse(value) ??
              DateTime.fromMillisecondsSinceEpoch(0);
        }
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    List<Map<String, dynamic>> parseAttachments(dynamic raw) {
      if (raw is! List) {
        return [];
      }

      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return Report(
      reportId: id,
      reporterUid: map['reporterUid'] ?? '',
      title: (map['title'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      tag: (map['tag'] ?? '').toString(),
      dateTime: parseFirestoreDate(map['dateTime']),
      location: (map['location'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      status: map['status'] ?? 'new',
      assignedCounsellorUid: map['assignedCounsellorUid'],
      createdAt: parseFirestoreDate(map['createdAt']),
      attachments: parseAttachments(map['attachments']),
    );
  }
}