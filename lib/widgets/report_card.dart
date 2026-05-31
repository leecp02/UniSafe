import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/report_controller.dart';
import '../models/report_model.dart';
import '../screens/report_page.dart';
import '../style/style.dart';

class ReportCard extends StatefulWidget {

  final Report report;
  final ReportController controller;

  const ReportCard({
    super.key,
    required this.report,
    required this.controller,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {

  bool isExpanded = false;
  bool isDeleting = false;
  int _currentAttachmentIndex = 0;
  final PageController _attachmentController = PageController();

  @override
  void didUpdateWidget(covariant ReportCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.reportId != widget.report.reportId) {
      _currentAttachmentIndex = 0;
    }
  }

  @override
  void dispose() {
    _attachmentController.dispose();
    super.dispose();
  }

  bool get _isOwner => FirebaseAuth.instance.currentUser?.uid == widget.report.reporterUid;

  Future<void> _openEditPage() async {
    if (!_isOwner) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Report'),
          ),
          body: ReportPage(initialReport: widget.report),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (!_isOwner || isDeleting) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete report?'),
          content: const Text(
            'This action cannot be undone. Do you want to permanently delete this submitted report?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() => isDeleting = true);

    try {
      await widget.controller.deleteReport(widget.report.reportId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report deleted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isDeleting = false);
    }
  }

  Widget _buildAttachmentWidget() {
    if (widget.report.attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool hasMultiple = widget.report.attachments.length > 1;

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: _attachmentController,
              itemCount: widget.report.attachments.length,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentAttachmentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final Map<String, dynamic> attachment = widget.report.attachments[index];
                final String attachmentData =
                    (attachment['attachmentData'] ?? '').toString();
                final String attachmentUrl =
                    (attachment['attachmentUrl'] ?? '').toString();

                if (attachmentData.isNotEmpty) {
                  try {
                    final Uint8List bytes = base64Decode(attachmentData);
                    return Image.memory(
                      bytes,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  } catch (_) {
                    return Container(
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Text('Attachment data is invalid.'),
                    );
                  }
                }

                if (attachmentUrl.isNotEmpty) {
                  return Image.network(
                    attachmentUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Text('Attachment not available.'),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          if (hasMultiple && _currentAttachmentIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
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
            ),
          if (hasMultiple && _currentAttachmentIndex < widget.report.attachments.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
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
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final report = widget.report;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // BASIC INFO
            Text(
              "Report ID: ${report.reportId}",
              style: CustomStyle.h5,
            ),

            const SizedBox(height: 6),

            Text(
              "Title: ${report.title}",
              style: CustomStyle.txt,
            ),

            Text(
              "DateTime: ${_formatDate(report.dateTime)}",
              style: CustomStyle.subtitle,
            ),

            const SizedBox(height: 10),

            // EXPAND BUTTON
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded
                        ? "Hide report details"
                        : "View report details",
                    style: CustomStyle.link2,
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),

            // EXPANDED CONTENT
            if (isExpanded) ...[

              const SizedBox(height: 12),
              const Divider(),

              const SizedBox(height: 8),

              Text("Category: ${report.category}", style: CustomStyle.txt),
              Text("Tag: ${report.tag}", style: CustomStyle.txt),
              Text("Location: ${report.location}", style: CustomStyle.txt),

              const SizedBox(height: 8),

              Text(
                "Description:",
                style: CustomStyle.h5,
              ),

              const SizedBox(height: 4),

              Text(
                report.description,
                style: CustomStyle.txt,
              ),

              const SizedBox(height: 10),

              // SHOW IMAGE IF EXISTS
              if (report.attachments.isNotEmpty)
                _buildAttachmentWidget(),

              const SizedBox(height: 14),
              if (_isOwner)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openEditPage,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    ElevatedButton.icon(
                      onPressed: isDeleting ? null : _confirmDelete,
                      icon: isDeleting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
            ]
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}