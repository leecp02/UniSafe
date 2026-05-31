import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../controllers/report_controller.dart';
import '../models/report_model.dart';
import '../screens/report_chat_page.dart';

class CounsellorReportCard extends StatefulWidget {
  final Report report;
  final ReportController controller;

  const CounsellorReportCard({
    super.key,
    required this.report,
    required this.controller,
  });

  @override
  State<CounsellorReportCard> createState() => _CounsellorReportCardState();
}

class _CounsellorReportCardState extends State<CounsellorReportCard> {
  static const statuses = <String>['new', 'in_progress', 'resolved', 'closed'];

  late String selectedStatus;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = statuses.contains(widget.report.status)
        ? widget.report.status
        : statuses.first;
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      selectedStatus = status;
      isUpdating = true;
    });

    try {
      await widget.controller.updateReportStatus(
        reportId: widget.report.reportId,
        status: status,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report status updated.')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Future<void> _showUpdateStatusPicker() async {
    final String? nextStatus = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final selected = status == selectedStatus;
              return ListTile(
                title: Text(status),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, status),
              );
            }).toList(),
          ),
        );
      },
    );

    if (nextStatus == null || nextStatus == selectedStatus) {
      return;
    }

    await _updateStatus(nextStatus);
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(value);
  }

  bool _isImageAttachment(Map<String, dynamic> attachment) {
    final String mime = (attachment['attachmentMime'] ?? attachment['mimeType'] ?? '').toString().toLowerCase();
    final String type = (attachment['attachmentType'] ?? attachment['type'] ?? '').toString().toLowerCase();
    return mime.startsWith('image/') || type == 'image';
  }

  Widget _buildAttachmentPreview(Map<String, dynamic> attachment, int index) {
    final String attachmentData = (attachment['attachmentData'] ?? '').toString();
    final String attachmentUrl = (attachment['attachmentUrl'] ?? '').toString();

    if (attachmentData.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(attachmentData);
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Attachment $index image data is invalid.'),
        );
      }
    }

    if (attachmentUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          attachmentUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Attachment $index could not be loaded.'),
            );
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('Attachment $index has no preview data.'),
    );
  }

  Future<void> _showImageViewer({
    Uint8List? bytes,
    String? imageUrl,
    required int index,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: bytes != null
                        ? Image.memory(bytes, fit: BoxFit.contain)
                        : (imageUrl != null && imageUrl.isNotEmpty)
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Image cannot be loaded.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No image available.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close image $index',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportReportAsPdf(Report report) async {
    final pdf = pw.Document();
    final imageAttachments = report.attachments.where(_isImageAttachment).toList();

    final List<pw.Widget> pdfImageWidgets = [];
    for (var i = 0; i < imageAttachments.length; i++) {
      final index = i + 1;
      final attachment = imageAttachments[i];
      final String attachmentData = (attachment['attachmentData'] ?? '').toString();
      final String attachmentUrl = (attachment['attachmentUrl'] ?? '').toString();

      if (attachmentData.isNotEmpty) {
        try {
          final imageBytes = base64Decode(attachmentData);
          final provider = pw.MemoryImage(imageBytes);
          pdfImageWidgets.addAll([
            pw.SizedBox(height: 8),
            pw.Text('Image $index'),
            pw.SizedBox(height: 6),
            pw.Container(
              height: 220,
              width: double.infinity,
              child: pw.Image(provider, fit: pw.BoxFit.contain),
            ),
          ]);
          continue;
        } catch (_) {
          pdfImageWidgets.add(pw.Text('Image $index could not be decoded.'));
          continue;
        }
      }

      if (attachmentUrl.isNotEmpty) {
        pdfImageWidgets.add(pw.Text('Image $index URL: $attachmentUrl'));
      } else {
        pdfImageWidgets.add(pw.Text('Image $index has no preview data.'));
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Incident Report',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Report ID: ${report.reportId}'),
          pw.Text('Title: ${report.title}'),
          pw.Text('Status: $selectedStatus'),
          pw.Text('Reporter UID: ${report.reporterUid}'),
          pw.Text(
            'Assigned Counsellor UID: ${report.assignedCounsellorUid?.isNotEmpty == true ? report.assignedCounsellorUid : '-'}',
          ),
          pw.SizedBox(height: 10),
          pw.Text('Category: ${report.category}'),
          pw.Text('Tag: ${report.tag}'),
          pw.Text('Incident Date/Time: ${_formatDateTime(report.dateTime)}'),
          pw.Text('Created At: ${_formatDateTime(report.createdAt)}'),
          pw.Text('Location: ${report.location}'),
          pw.SizedBox(height: 10),
          pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(report.description),
          pw.SizedBox(height: 10),
          pw.Text(
            'Attachments: ${report.attachments.length}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...report.attachments.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final fileName = (item['fileName'] ?? item['name'] ?? 'Attachment $index').toString();
            final mimeType = (item['mimeType'] ?? item['type'] ?? '').toString();
            return pw.Text(
              mimeType.isEmpty ? '$index. $fileName' : '$index. $fileName ($mimeType)',
            );
          }),
          if (pdfImageWidgets.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Attached Images',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            ...pdfImageWidgets,
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      name: 'incident_report_${report.reportId}.pdf',
      onLayout: (format) => pdf.save(),
    );
  }

  Future<void> _showReportDetailsDialog() async {
    final report = widget.report;
    final theme = Theme.of(context);
    final imageAttachments = report.attachments.where(_isImageAttachment).toList();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Title: ${report.title}'),
                  Text('Report ID: ${report.reportId}'),
                  Text('Status: $selectedStatus'),
                  Text('Reporter UID: ${report.reporterUid}'),
                  Text(
                    'Assigned Counsellor UID: ${report.assignedCounsellorUid?.isNotEmpty == true ? report.assignedCounsellorUid : '-'}',
                  ),
                  const SizedBox(height: 10),
                  Text('Category: ${report.category}'),
                  Text('Tag: ${report.tag}'),
                  Text('Incident Date/Time: ${_formatDateTime(report.dateTime)}'),
                  Text('Created At: ${_formatDateTime(report.createdAt)}'),
                  Text('Location: ${report.location}'),
                  const SizedBox(height: 10),
                  Text(
                    'Description',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(report.description),
                  const SizedBox(height: 10),
                  Text(
                    'Attachments (${report.attachments.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (imageAttachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Attached Images',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...imageAttachments.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final item = entry.value;
                      final attachmentData = (item['attachmentData'] ?? '').toString();
                      final attachmentUrl = (item['attachmentUrl'] ?? '').toString();

                      Uint8List? bytes;
                      if (attachmentData.isNotEmpty) {
                        try {
                          bytes = base64Decode(attachmentData);
                        } catch (_) {
                          bytes = null;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            _showImageViewer(
                              bytes: bytes,
                              imageUrl: attachmentUrl,
                              index: index,
                            );
                          },
                          child: _buildAttachmentPreview(item, index),
                        ),
                      );
                    }),
                  ],
                  if (report.attachments.isEmpty)
                    const Text('No attachments')
                  else
                    ...report.attachments.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final item = entry.value;
                      final fileName = (item['fileName'] ?? item['name'] ?? 'Attachment $index').toString();
                      final mimeType = (item['mimeType'] ?? item['type'] ?? '').toString();

                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          mimeType.isEmpty
                              ? '$index. $fileName'
                              : '$index. $fileName ($mimeType)',
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await _exportReportAsPdf(report);
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Export PDF'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showReportDetailsDialog,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text('Report ID: ${report.reportId}', style: const TextStyle(fontSize: 12)),
              Text('Status: $selectedStatus', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Open full report details'),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: isUpdating ? null : _showUpdateStatusPicker,
                    icon: isUpdating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.update_outlined),
                    label: const Text('Update Status'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;
                      if (currentUid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in again.')),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportChatPage(
                            reportId: report.reportId,
                            peerUid: report.reporterUid,
                            counsellorUid: currentUid,
                            studentUid: report.reporterUid,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Chat'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
