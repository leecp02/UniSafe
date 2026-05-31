import 'event_attachment_model.dart';

class EventPost {

  final String eventId;
  final String eventTitle;
  final String eventDesc;
  final DateTime eventDate;
  final String eventVenue;
  final String userId;
  final DateTime createdAt;
  final List<EventAttachment> attachments;

  EventPost({
    required this.eventId,
    required this.eventTitle,
    required this.eventDesc,
    required this.eventDate,
    required this.eventVenue,
    required this.userId,
    required this.createdAt,
    required this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventTitle': eventTitle,
      'eventDesc': eventDesc,
      'eventDate': eventDate,
      'eventVenue': eventVenue,
      'userId': userId,
      'createdAt': createdAt,
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }

  factory EventPost.fromMap(String id, Map<String, dynamic> map) {
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

    final List attachmentList = map['attachments'] ?? [];

    return EventPost(
      eventId: id,
      eventTitle: (map['eventTitle'] ?? '').toString(),
      eventDesc: (map['eventDesc'] ?? '').toString(),
      eventDate: parseFirestoreDate(map['eventDate']),
      eventVenue: (map['eventVenue'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      createdAt: parseFirestoreDate(map['createdAt']),
      attachments: attachmentList
          .whereType<Map>()
          .map((a) => EventAttachment.fromMap(Map<String, dynamic>.from(a)))
          .toList(),
    );
  }
}