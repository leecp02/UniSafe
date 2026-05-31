import 'forum_attachment_model.dart';

class ForumPost {

  final String postId;
  final String postTitle;
  final String postDesc;
  final String userId;
  final DateTime createdAt;
  final List<ForumAttachment> attachments;

  ForumPost({
    required this.postId,
    required this.postTitle,
    required this.postDesc,
    required this.userId,
    required this.createdAt,
    required this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      'postTitle': postTitle,
      'postDesc': postDesc,
      'userId': userId,
      'createdAt': createdAt,
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }

  factory ForumPost.fromMap(String id, Map<String, dynamic> map) {

    List attachmentsList = map['attachments'] ?? [];
    final dynamic rawTitle = map['postTitle'] ?? map['title'];
    final dynamic rawDesc = map['postDesc'] ?? map['description'] ?? map['desc'];
    final dynamic rawUserId = map['userId'];
    final dynamic rawCreatedAt = map['createdAt'];

    return ForumPost(
      postId: id,
      postTitle: (rawTitle ?? '').toString(),
      postDesc: (rawDesc ?? '').toString(),
      userId: (rawUserId ?? '').toString(),
      createdAt: rawCreatedAt != null
          ? rawCreatedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      attachments: attachmentsList
          .whereType<Map>()
          .map((a) => ForumAttachment.fromMap(Map<String, dynamic>.from(a)))
          .where((a) =>
              a.attachmentUrl.trim().isNotEmpty ||
              (a.attachmentData?.trim().isNotEmpty ?? false))
          .toList(),
    );
  }
}