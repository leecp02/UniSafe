class ReportChatMessage {
  final String messageId;
  final String reportId;
  final String senderUid;
  final String receiverUid;
  final String message;
  final DateTime createdAt;

  const ReportChatMessage({
    required this.messageId,
    required this.reportId,
    required this.senderUid,
    required this.receiverUid,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'message': message,
      'createdAt': createdAt,
    };
  }

  factory ReportChatMessage.fromMap(String id, Map<String, dynamic> map) {
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

    return ReportChatMessage(
      messageId: id,
      reportId: (map['reportId'] ?? '').toString(),
      senderUid: (map['senderUid'] ?? '').toString(),
      receiverUid: (map['receiverUid'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      createdAt: parseFirestoreDate(map['createdAt']),
    );
  }
}
