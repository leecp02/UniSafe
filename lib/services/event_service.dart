import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_post_model.dart';

class EventService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createEvent(EventPost eventPost) async {
    try {
      await firestore.collection('event_posts').add({
        ...eventPost.toMap(),
        'attachments': eventPost.attachments.map((a) => a.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown Firestore create error.';
      throw Exception('Create event failed [${e.code}]: $message');
    }
  }

  Future<void> updateEvent(EventPost eventPost) async {
    try {
      await firestore.collection('event_posts').doc(eventPost.eventId).update({
        ...eventPost.toMap(),
        'attachments': eventPost.attachments.map((a) => a.toMap()).toList(),
      });
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown Firestore update error.';
      throw Exception('Update event failed [${e.code}]: $message');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await firestore.collection('event_posts').doc(eventId).delete();
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown Firestore delete error.';
      throw Exception('Delete event failed [${e.code}]: $message');
    }
  }

  Stream<List<EventPost>> getEvents() {
    return firestore
        .collection('event_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventPost.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}
