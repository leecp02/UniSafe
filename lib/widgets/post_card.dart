import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../controllers/forum_controller.dart';
import '../models/forum_post_model.dart';
import '../screens/create_forum_post_page.dart';

class PostCard extends StatefulWidget {

  final ForumPost post;
  final ForumController controller;

  const PostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isEditing = false;
  bool _isExpanded = false;
  int _currentAttachmentIndex = 0;
  final PageController _attachmentController = PageController();

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.postId != widget.post.postId) {
      _isExpanded = false;
      _currentAttachmentIndex = 0;
    }
  }

  @override
  void dispose() {
    _attachmentController.dispose();
    super.dispose();
  }

  bool get _isOwner {
    return FirebaseAuth.instance.currentUser?.uid == widget.post.userId;
  }

  Future<void> _openFullEditScreen() async {
    if (_isEditing) return;

    setState(() {
      _isEditing = true;
    });

    try {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateForumPostPage(initialPost: widget.post),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open editor: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isEditing = false;
      });
    }
  }

  Widget _buildAttachmentWidget({required bool expanded}) {
    if (widget.post.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final double imageHeight = expanded ? 260 : 170;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _attachmentController,
              itemCount: widget.post.attachments.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentAttachmentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final attachment = widget.post.attachments[index];
                return _buildAttachmentPreview(
                  attachment: attachment,
                  imageHeight: imageHeight,
                );
              },
            ),
          ),
          if (widget.post.attachments.length > 1) ...[
            Positioned(
              left: 4,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: _currentAttachmentIndex == 0,
                child: Center(
                  child: Opacity(
                    opacity: _currentAttachmentIndex == 0 ? 0.25 : 0.9,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 18,
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: _currentAttachmentIndex == 0
                            ? null
                            : () {
                                _attachmentController.previousPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                );
                              },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: _currentAttachmentIndex == widget.post.attachments.length - 1,
                child: Center(
                  child: Opacity(
                    opacity:
                        _currentAttachmentIndex == widget.post.attachments.length - 1
                            ? 0.25
                            : 0.9,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 18,
                        padding: const EdgeInsets.all(8),
                        icon: const Icon(Icons.chevron_right, color: Colors.white),
                        onPressed:
                            _currentAttachmentIndex == widget.post.attachments.length - 1
                                ? null
                                : () {
                                    _attachmentController.nextPage(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                    );
                                  },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview({
    required dynamic attachment,
    required double imageHeight,
  }) {
    final String data = (attachment.attachmentData ?? '').toString();
    final String url = attachment.attachmentUrl.toString();

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
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade200,
          child: const Center(child: Text("Attachment data is invalid.")),
        );
      }
    }

    if (url.isNotEmpty) {
      return Image.network(
        url,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: double.infinity,
            height: imageHeight,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade200,
            child: const Center(child: Text("Attachment not available.")),
          );
        },
      );
    }

    return const SizedBox.shrink();
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
                      widget.post.postTitle.isEmpty
                          ? "Untitled post"
                          : widget.post.postTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isOwner)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: _isEditing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit, size: 20),
                      tooltip: "Edit post",
                      onPressed: _isEditing ? null : _openFullEditScreen,
                    ),
                ],
              ),

              Text(
                widget.post.postDesc,
                style: const TextStyle(fontSize: 15),
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),

              if (widget.post.postDesc.length > 140)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(_isExpanded ? "Show less" : "Show more"),
                  ),
                ),

              const SizedBox(height: 10),

              if (widget.post.attachments.isNotEmpty)
                _buildAttachmentWidget(expanded: _isExpanded),

              const SizedBox(height: 10),

              Text(
                "Posted by ${widget.post.userId}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(widget.post.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}