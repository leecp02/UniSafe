import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/report_chat_thread_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/report_chat_service.dart';
import 'report_chat_page.dart';

class MessagesPage extends StatefulWidget {
  final bool isCounsellor;

  const MessagesPage({
    super.key,
    required this.isCounsellor,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final AuthService _authService = AuthService();
  final ReportChatService _chatService = ReportChatService();
  String? _markedReadUid;

  @override
  void initState() {
    super.initState();
    _markThreadsReadOnOpen();
  }

  Future<void> _markThreadsReadOnOpen() async {
    final profile = await _authService.getCurrentUserProfile();
    if (!mounted || profile == null) {
      return;
    }

    if (_markedReadUid == profile.uid) {
      return;
    }

    _markedReadUid = profile.uid;
    await _chatService.markAllThreadsAsRead(
      uid: profile.uid,
      isCounsellor: widget.isCounsellor,
    );
  }

  Stream<List<ReportChatThread>> _threadStream(
    ReportChatService chatService,
    String uid,
  ) {
    if (widget.isCounsellor) {
      return chatService.getThreadsForCounsellor(uid);
    }
    return chatService.getThreadsForStudent(uid);
  }

  Stream<UserModel?> _peerProfileStream(String peerUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(peerUid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return UserModel.fromMap(
        snapshot.id,
        snapshot.data() ?? <String, dynamic>{},
      );
    });
  }

  String _subtitle(ReportChatThread thread) {
    final stamp = DateFormat('dd MMM, HH:mm').format(thread.updatedAt);
    return 'Report ${thread.reportId} • $stamp\n${thread.lastMessage}';
  }

  String _displayName(UserModel? profile) {
    if (profile == null) {
      return widget.isCounsellor ? 'Student' : 'Counsellor';
    }

    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final username = profile.username.trim();
    if (username.isNotEmpty) {
      return username;
    }

    return widget.isCounsellor ? 'Student' : 'Counsellor';
  }

  String _peerInfo(UserModel? profile) {
    if (profile == null) {
      return widget.isCounsellor
          ? 'Student profile not loaded yet.'
          : 'Counsellor profile not loaded yet.';
    }

    if (widget.isCounsellor) {
      final details = <String>[];

      if (profile.matricNumber.trim().isNotEmpty) {
        details.add('Matric ${profile.matricNumber.trim()}');
      }
      if (profile.faculty.trim().isNotEmpty) {
        details.add(profile.faculty.trim());
      }
      if (profile.programme.trim().isNotEmpty) {
        details.add(profile.programme.trim());
      }

      return details.isEmpty ? 'Student profile' : details.join(' • ');
    }

    return 'Counsellor profile';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _authService.watchCurrentUserProfile(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;
        if (profile == null) {
          return const Center(child: Text('Please sign in to view messages.'));
        }

        if (_markedReadUid != profile.uid) {
          _markedReadUid = profile.uid;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _chatService.markAllThreadsAsRead(
              uid: profile.uid,
              isCounsellor: widget.isCounsellor,
            );
          });
        }

        return StreamBuilder<List<ReportChatThread>>(
          stream: _threadStream(_chatService, profile.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Failed to load chats: ${snapshot.error}'),
              );
            }

            final threads = snapshot.data ?? <ReportChatThread>[];
            if (threads.isEmpty) {
              return Center(
                child: Text(
                  widget.isCounsellor
                      ? 'No student chats yet.'
                      : 'No counsellor chats yet.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                final peerUid = widget.isCounsellor ? thread.studentUid : thread.counsellorUid;
                return StreamBuilder<UserModel?>(
                  stream: _peerProfileStream(peerUid),
                  builder: (context, profileSnapshot) {
                    final peerProfile = profileSnapshot.data;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            widget.isCounsellor
                                ? Icons.school_outlined
                                : Icons.support_agent_outlined,
                          ),
                        ),
                        title: Text(
                          widget.isCounsellor
                              ? 'Student: ${_displayName(peerProfile)}'
                              : 'Counsellor: ${_displayName(peerProfile)}',
                        ),
                        subtitle: Text(
                          '${_peerInfo(peerProfile)}\n${_subtitle(thread)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportChatPage(
                                reportId: thread.reportId,
                                peerUid: peerUid,
                                counsellorUid: thread.counsellorUid,
                                studentUid: thread.studentUid,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
