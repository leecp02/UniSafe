class ForumAttachment {

  final String attachmentUrl;
  final String attachmentType;
  final String? attachmentData;
  final String? attachmentMime;

  ForumAttachment({
    required this.attachmentUrl,
    required this.attachmentType,
    this.attachmentData,
    this.attachmentMime,
  });

  Map<String, dynamic> toMap() {
    return {
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'attachmentData': attachmentData,
      'attachmentMime': attachmentMime,
    };
  }

  factory ForumAttachment.fromMap(Map<String, dynamic> map) {
    return ForumAttachment(
      attachmentUrl: (map['attachmentUrl'] ?? '').toString(),
      attachmentType: (map['attachmentType'] ?? 'image').toString(),
      attachmentData: map['attachmentData']?.toString(),
      attachmentMime: map['attachmentMime']?.toString(),
    );
  }
}