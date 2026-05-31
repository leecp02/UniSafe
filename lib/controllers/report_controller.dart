import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report_dashboard_stats_model.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/attachment_storage_service.dart';

class ReportController {

  final ReportService reportService = ReportService();
  final AttachmentStorageService storageService =
      AttachmentStorageService();

  Future<void> createReport({
    required String title,
    required String category,
    required String tag,
    required DateTime dateTime,
    required String location,
    required String description,
    XFile? evidenceFile,
    List<XFile>? evidenceFiles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("You must be signed in to submit a report.");
    }

    final String cleanedTitle = title.trim();
    final String cleanedDesc = description.trim();
    final String cleanedLocation = location.trim();

    _validateFields(
      cleanedTitle,
      category,
      cleanedDesc,
      cleanedLocation,
    );

    List<Map<String, dynamic>> attachments = [];
    final List<XFile> filesToUpload = [
      ...?evidenceFiles,
      if (evidenceFile != null) evidenceFile,
    ];

    // Upload evidence (if any)
    if (filesToUpload.isNotEmpty) {
      final builtAttachments =
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

    final report = Report(
      reportId: '',
      reporterUid: user.uid,
      title: cleanedTitle,
      category: category,
      tag: tag,
      dateTime: dateTime,
      location: cleanedLocation,
      description: cleanedDesc,
      status: 'new',
      assignedCounsellorUid: null,
      createdAt: DateTime.now(),
      attachments: attachments,
    );

    await reportService.createReport(report);
  }

  Future<void> updateReport({
    required Report report,
    required String title,
    required String category,
    required String tag,
    required DateTime dateTime,
    required String location,
    required String description,
    XFile? evidenceFile,
    List<XFile>? evidenceFiles,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to update a report.');
    }

    final String cleanedTitle = title.trim();
    final String cleanedDesc = description.trim();
    final String cleanedLocation = location.trim();

    _validateFields(
      cleanedTitle,
      category,
      cleanedDesc,
      cleanedLocation,
    );

    List<Map<String, dynamic>> attachments = report.attachments.toList();
    final List<XFile> filesToUpload = [
      ...?evidenceFiles,
      if (evidenceFile != null) evidenceFile,
    ];

    if (filesToUpload.isNotEmpty) {
      final builtAttachments =
          await storageService.buildInlineImageAttachments(filesToUpload);

      attachments.addAll(
        builtAttachments
          .map(
            (attachment) => {
              'attachmentUrl': attachment['attachmentUrl'] ?? '',
              'attachmentType': attachment['attachmentType'] ?? 'image',
              'attachmentData': attachment['attachmentData'],
              'attachmentMime': attachment['attachmentMime'],
            },
          )
          .toList(),
      );
    }

    await reportService.updateReport(
      reportId: report.reportId,
      reporterUid: report.reporterUid,
      title: cleanedTitle,
      category: category,
      tag: tag,
      dateTime: dateTime,
      location: cleanedLocation,
      description: cleanedDesc,
      status: report.status,
      assignedCounsellorUid: report.assignedCounsellorUid,
      createdAt: report.createdAt,
      attachments: attachments,
    );
  }

  Future<void> deleteReport(String reportId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to delete a report.');
    }

    await reportService.deleteReport(reportId);
  }

  void _validateFields(
    String title,
    String category,
    String desc,
    String location,
  ) {

    if (title.isEmpty) {
      throw Exception("Title cannot be empty");
    }

    if (category.isEmpty) {
      throw Exception("Category must be selected");
    }

    if (desc.isEmpty) {
      throw Exception("Description cannot be empty");
    }

    if (location.isEmpty) {
      throw Exception("Location cannot be empty");
    }
  }

  Stream<List<Report>> getReports({required bool includeAll}) {
    return reportService.getReports(includeAll: includeAll);
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to update report status.');
    }

    await reportService.updateReportStatus(
      reportId: reportId,
      status: status,
      assignedCounsellorUid: user.uid,
    );
  }

  Stream<ReportDashboardStats> watchDashboardStats() {
    return reportService.watchDashboardStats();
  }
}