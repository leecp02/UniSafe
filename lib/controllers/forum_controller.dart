import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/forum_post_model.dart';
import '../models/forum_attachment_model.dart';
import '../services/forum_service.dart';
import '../services/attachment_storage_service.dart';

class ForumController {

  final ForumService forumService = ForumService();
  final AttachmentStorageService storageService =
      AttachmentStorageService();

  // CREATE POST
  Future<void> createPost({
    required String postTitle,
    required String postDesc,
    XFile? attachmentFile,
    List<XFile>? attachmentFiles,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User must be logged in.");
    }

    final String cleanedTitle = postTitle.trim();
    final String cleanedDesc = postDesc.trim();

    if (cleanedTitle.isEmpty || cleanedDesc.isEmpty) {
      throw Exception("Title and description cannot be empty.");
    }

    List<ForumAttachment> attachments = [];
    final List<XFile> filesToUpload = [
      ...?attachmentFiles,
      if (attachmentFile != null) attachmentFile,
    ];

    if (filesToUpload.isNotEmpty) {
      final List<Map<String, String>> builtAttachments =
          await storageService.buildInlineImageAttachments(filesToUpload);

      attachments = builtAttachments
          .map(
            (attachment) => ForumAttachment(
              attachmentUrl: attachment['attachmentUrl'] ?? '',
              attachmentType: attachment['attachmentType'] ?? 'image',
              attachmentData: attachment['attachmentData'],
              attachmentMime: attachment['attachmentMime'],
            ),
          )
          .toList();
    }

    final post = ForumPost(
      postId: '',
      postTitle: cleanedTitle,
      postDesc: cleanedDesc,
      userId: user.uid,
      createdAt: DateTime.now(),
      attachments: attachments,
    );

    await forumService.createPost(post);
  }

  // ✅ ADD THIS BACK (FIX)
  Future<void> updatePost({
    required String postId,
    required String postTitle,
    required String postDesc,
    required String existingUserId,
    required DateTime existingCreatedAt,
    XFile? attachmentFile,
    List<XFile>? attachmentFiles,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User must be logged in.");
    }

    final String cleanedTitle = postTitle.trim();
    final String cleanedDesc = postDesc.trim();

    if (cleanedTitle.isEmpty || cleanedDesc.isEmpty) {
      throw Exception("Title and description cannot be empty.");
    }

    List<Map<String, dynamic>> attachments = [];
    final List<XFile> filesToUpload = [
      ...?attachmentFiles,
      if (attachmentFile != null) attachmentFile,
    ];

    // ✅ Only update attachment if new files selected
    if (filesToUpload.isNotEmpty) {
      final List<Map<String, String>> builtAttachments =
          await storageService.buildInlineImageAttachments(filesToUpload);

      attachments = builtAttachments
          .map(
            (attachment) => {
              "attachmentUrl": attachment['attachmentUrl'] ?? '',
              "attachmentType": attachment['attachmentType'] ?? 'image',
              "attachmentData": attachment['attachmentData'],
              "attachmentMime": attachment['attachmentMime'],
            },
          )
          .toList();
    }

    await forumService.updatePost(
      postId: postId,
      postTitle: cleanedTitle,
      postDesc: cleanedDesc,
      userId: existingUserId,
      createdAt: existingCreatedAt,
      attachments: attachments.isEmpty ? null : attachments,
    );
  }

  // GET POSTS
  Stream<List<ForumPost>> getPosts() {
    return forumService.getPosts();
  }
}