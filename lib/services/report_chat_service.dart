import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_chat_message_model.dart';
import '../models/report_chat_thread_model.dart';

class ReportChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String _threadId({
    required String reportId,
    required String counsellorUid,
    required String studentUid,
  }) {
    return '${reportId}_${counsellorUid}_$studentUid';
  }

  Stream<List<ReportChatMessage>> getMessagesByReport(String reportId) {
    return firestore
        .collection('report_chats')
        .where('reportId', isEqualTo: reportId)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportChatMessage.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> sendMessage({
    required String reportId,
    required String senderUid,
    required String receiverUid,
    required String message,
    required String counsellorUid,
    required String studentUid,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    await firestore.collection('report_chats').add({
      'reportId': reportId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'message': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final threadId = _threadId(
      reportId: reportId,
      counsellorUid: counsellorUid,
      studentUid: studentUid,
    );

    await firestore.collection('report_chat_threads').doc(threadId).set({
      'reportId': reportId,
      'counsellorUid': counsellorUid,
      'studentUid': studentUid,
      'lastMessage': trimmed,
      'lastMessageSenderUid': senderUid,
      'updatedAt': FieldValue.serverTimestamp(),
      if (senderUid == counsellorUid)
        'lastReadByCounsellorAt': FieldValue.serverTimestamp()
      else
        'lastReadByStudentAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markAllThreadsAsRead({
    required String uid,
    required bool isCounsellor,
  }) async {
    final field = isCounsellor ? 'counsellorUid' : 'studentUid';
    final readField =
        isCounsellor ? 'lastReadByCounsellorAt' : 'lastReadByStudentAt';

    final snapshot = await firestore
        .collection('report_chat_threads')
        .where(field, isEqualTo: uid)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = firestore.batch();
    var updatedAny = false;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if ((data['lastMessageSenderUid'] ?? '').toString() == uid) {
        continue;
      }

      batch.set(doc.reference, {
        readField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      updatedAny = true;
    }

    if (!updatedAny) {
      return;
    }

    await batch.commit();
  }

  Stream<List<ReportChatThread>> getThreadsForCounsellor(String counsellorUid) {
    return firestore
        .collection('report_chat_threads')
        .where('counsellorUid', isEqualTo: counsellorUid)
        .snapshots()
        .map((snapshot) {
      final threads = snapshot.docs
          .map((doc) => ReportChatThread.fromMap(doc.id, doc.data()))
          .toList();

      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return threads;
    });
  }

  Stream<List<ReportChatThread>> getThreadsForStudent(String studentUid) {
    return firestore
        .collection('report_chat_threads')
        .where('studentUid', isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) {
      final threads = snapshot.docs
          .map((doc) => ReportChatThread.fromMap(doc.id, doc.data()))
          .toList();

      threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return threads;
    });
  }
}
