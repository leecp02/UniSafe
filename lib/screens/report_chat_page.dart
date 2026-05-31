import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/report_chat_message_model.dart';
import '../services/report_chat_service.dart';

class ReportChatPage extends StatefulWidget {
  final String reportId;
  final String peerUid;
  final String counsellorUid;
  final String studentUid;

  const ReportChatPage({
    super.key,
    required this.reportId,
    required this.peerUid,
    required this.counsellorUid,
    required this.studentUid,
  });

  @override
  State<ReportChatPage> createState() => _ReportChatPageState();
}

class _ReportChatPageState extends State<ReportChatPage> {
  final ReportChatService chatService = ReportChatService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();

  bool isSending = false;

  Future<void> _send() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || isSending) {
      return;
    }

    setState(() => isSending = true);

    try {
      await chatService.sendMessage(
        reportId: widget.reportId,
        senderUid: currentUser.uid,
        receiverUid: widget.peerUid,
        message: messageController.text,
        counsellorUid: widget.counsellorUid,
        studentUid: widget.studentUid,
      );
      messageController.clear();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access chat.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Report Chat: ${widget.reportId}'),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: firestore.collection('reports').doc(widget.reportId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'This report may have been deleted by the student. Chat history is kept for reference.',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }

              final doc = snapshot.data;
              if (doc != null && !doc.exists) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'This report was deleted by the student. Chat history is kept for reference.',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: StreamBuilder<List<ReportChatMessage>>(
              stream: chatService.getMessagesByReport(widget.reportId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load chat: ${snapshot.error}'),
                  );
                }

                final messages = snapshot.data ?? <ReportChatMessage>[];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet for this report.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderUid == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color.fromARGB(255, 215, 235, 255)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.message),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(message.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isSending ? null : _send,
                    icon: isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
