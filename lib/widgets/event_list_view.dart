import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/event_controller.dart';
import '../models/event_post_model.dart';
import '../screens/create_event_post_page.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = EventController();

    return StreamBuilder<List<EventPost>>(
      stream: controller.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load events: ${snapshot.error}'),
          );
        }

        final events = snapshot.data ?? <EventPost>[];
        if (events.isEmpty) {
          return const Center(child: Text('No events yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _EventCard(event: events[index]);
          },
        );
      },
    );
  }
}

class _EventCard extends StatefulWidget {
  final EventPost event;

  const _EventCard({required this.event});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool _isExpanded = false;
  int _currentAttachmentIndex = 0;
  bool _isEditing = false;
  bool _isDeleting = false;
  final PageController _attachmentController = PageController();

  bool get _isOwner {
    return FirebaseAuth.instance.currentUser?.uid == widget.event.userId;
  }

  Future<void> _openEditScreen() async {
    if (_isEditing) {
      return;
    }

    setState(() {
      _isEditing = true;
    });

    try {
      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateEventPostPage(initialEvent: widget.event),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open editor: $e')),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
      });
    }
  }

  Future<void> _deleteEvent() async {
    if (_isDeleting) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await EventController().deleteEvent(widget.event.eventId);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  void dispose() {
    _attachmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.event.eventTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isOwner)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: _isEditing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit event',
                          onPressed: _isEditing ? null : _openEditScreen,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: _isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.delete_outline, size: 20),
                          tooltip: 'Delete event',
                          onPressed: _isDeleting ? null : _deleteEvent,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy').format(widget.event.eventDate),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                widget.event.eventVenue,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                widget.event.eventDesc,
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (widget.event.eventDesc.length > 140)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(_isExpanded ? 'Show less' : 'Show more'),
                  ),
                ),
              if (widget.event.attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildAttachments(expanded: _isExpanded),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachments({required bool expanded}) {
    final double imageHeight = expanded ? 260 : 170;
    final bool hasMultiple = widget.event.attachments.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: imageHeight,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PageView.builder(
                  controller: _attachmentController,
                  itemCount: widget.event.attachments.length,
                  onPageChanged: (index) {
                    if (!mounted) return;
                    setState(() {
                      _currentAttachmentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final attachment = widget.event.attachments[index];
                    return _buildAttachmentPreview(
                      attachment: attachment,
                      imageHeight: imageHeight,
                    );
                  },
                ),
              ),
              if (hasMultiple && _currentAttachmentIndex > 0)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              if (hasMultiple && _currentAttachmentIndex < widget.event.attachments.length - 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasMultiple) ...[
          const SizedBox(height: 6),
          Text(
            '${_currentAttachmentIndex + 1}/${widget.event.attachments.length}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentPreview({
    required dynamic attachment,
    required double imageHeight,
  }) {
    final String data = (attachment.attachmentData ?? '').toString();
    final String url = (attachment.attachmentUrl).toString();

    if (data.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(data);
        return Image.memory(
          bytes,
          height: imageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return Container(
          width: double.infinity,
          height: imageHeight,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Text('Attachment data is invalid.'),
        );
      }
    }

    if (url.isNotEmpty) {
      return Image.network(
        url,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: imageHeight,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Text('Attachment not available.'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}