import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/event_attachment_model.dart';
import '../models/event_post_model.dart';
import '../services/attachment_storage_service.dart';
import '../services/event_service.dart';

class EventController {
  final EventService eventService = EventService();
  final AttachmentStorageService storageService = AttachmentStorageService();

  Future<void> createEvent({
    required String eventTitle,
    required String eventDesc,
    required DateTime eventDate,
    required String eventVenue,
    XFile? attachmentFile,
    List<XFile>? attachmentFiles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in.');
    }

    final cleanedTitle = eventTitle.trim();
    final cleanedDesc = eventDesc.trim();
    final cleanedVenue = eventVenue.trim();

    if (cleanedTitle.isEmpty || cleanedDesc.isEmpty || cleanedVenue.isEmpty) {
      throw Exception('Title, venue and description cannot be empty.');
    }

    final List<XFile> filesToUpload = [
      ...?attachmentFiles,
      if (attachmentFile != null) attachmentFile,
    ];
    final attachments = <EventAttachment>[];

    if (filesToUpload.isNotEmpty) {
      final builtAttachments =
          await storageService.buildInlineImageAttachments(filesToUpload);
      attachments.addAll(
        builtAttachments.map(
          (attachment) => EventAttachment(
            attachmentUrl: attachment['attachmentUrl'] ?? '',
            attachmentType: attachment['attachmentType'] ?? 'image',
            attachmentData: attachment['attachmentData'],
            attachmentMime: attachment['attachmentMime'],
          ),
        ),
      );
    }

    final eventPost = EventPost(
      eventId: '',
      eventTitle: cleanedTitle,
      eventDesc: cleanedDesc,
      eventDate: eventDate,
      eventVenue: cleanedVenue,
      userId: user.uid,
      createdAt: DateTime.now(),
      attachments: attachments,
    );

    await eventService.createEvent(eventPost);
  }

  Future<void> updateEvent({
    required String eventId,
    required String eventTitle,
    required String eventDesc,
    required DateTime eventDate,
    required String eventVenue,
    required String existingUserId,
    required DateTime existingCreatedAt,
    List<EventAttachment>? existingAttachments,
    XFile? attachmentFile,
    List<XFile>? attachmentFiles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in.');
    }

    final cleanedTitle = eventTitle.trim();
    final cleanedDesc = eventDesc.trim();
    final cleanedVenue = eventVenue.trim();

    if (cleanedTitle.isEmpty || cleanedDesc.isEmpty || cleanedVenue.isEmpty) {
      throw Exception('Title, venue and description cannot be empty.');
    }

    final List<XFile> filesToUpload = [
      ...?attachmentFiles,
      if (attachmentFile != null) attachmentFile,
    ];

    List<EventAttachment> attachments = existingAttachments ?? <EventAttachment>[];

    if (filesToUpload.isNotEmpty) {
      final builtAttachments =
          await storageService.buildInlineImageAttachments(filesToUpload);

      attachments = builtAttachments
          .map(
            (attachment) => EventAttachment(
              attachmentUrl: attachment['attachmentUrl'] ?? '',
              attachmentType: attachment['attachmentType'] ?? 'image',
              attachmentData: attachment['attachmentData'],
              attachmentMime: attachment['attachmentMime'],
            ),
          )
          .toList();
    }

    final eventPost = EventPost(
      eventId: eventId,
      eventTitle: cleanedTitle,
      eventDesc: cleanedDesc,
      eventDate: eventDate,
      eventVenue: cleanedVenue,
      userId: existingUserId,
      createdAt: existingCreatedAt,
      attachments: attachments,
    );

    await eventService.updateEvent(eventPost);
  }

  Future<void> deleteEvent(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in.');
    }

    await eventService.deleteEvent(eventId);
  }

  Stream<List<EventPost>> getEvents() {
    return eventService.getEvents();
  }
}
