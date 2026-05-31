class ReportChatThread {
  final String threadId;
  final String reportId;
  final String counsellorUid;
  final String studentUid;
  final String lastMessage;
  final String lastMessageSenderUid;
  final DateTime updatedAt;
  final DateTime? lastReadByCounsellorAt;
  final DateTime? lastReadByStudentAt;

  const ReportChatThread({
    required this.threadId,
    required this.reportId,
    required this.counsellorUid,
    required this.studentUid,
    required this.lastMessage,
    required this.lastMessageSenderUid,
    required this.updatedAt,
    this.lastReadByCounsellorAt,
    this.lastReadByStudentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'counsellorUid': counsellorUid,
      'studentUid': studentUid,
      'lastMessage': lastMessage,
      'lastMessageSenderUid': lastMessageSenderUid,
      'updatedAt': updatedAt,
      'lastReadByCounsellorAt': lastReadByCounsellorAt,
      'lastReadByStudentAt': lastReadByStudentAt,
    };
  }

  factory ReportChatThread.fromMap(String id, Map<String, dynamic> map) {
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
          return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
        }
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    DateTime? parseNullableFirestoreDate(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is DateTime) {
        return value;
      }

      try {
        return value.toDate();
      } catch (_) {
        if (value is String) {
          return DateTime.tryParse(value);
        }
        return null;
      }
    }

    return ReportChatThread(
      threadId: id,
      reportId: (map['reportId'] ?? '').toString(),
      counsellorUid: (map['counsellorUid'] ?? '').toString(),
      studentUid: (map['studentUid'] ?? '').toString(),
      lastMessage: (map['lastMessage'] ?? '').toString(),
      lastMessageSenderUid: (map['lastMessageSenderUid'] ?? '').toString(),
      updatedAt: parseFirestoreDate(map['updatedAt']),
      lastReadByCounsellorAt: parseNullableFirestoreDate(map['lastReadByCounsellorAt']),
      lastReadByStudentAt: parseNullableFirestoreDate(map['lastReadByStudentAt']),
    );
  }
}
