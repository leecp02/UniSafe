import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report_dashboard_stats_model.dart';
import '../models/report_model.dart';

class ReportService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createReport(Report report) async {

    try {

      await firestore.collection("reports").add({
        ...report.toMap(),
        "createdAt": FieldValue.serverTimestamp(),
      });

    } on FirebaseException catch (e) {

      final message = e.message ?? "Unknown error";
      throw Exception("Create report failed [${e.code}]: $message");
    }
  }

  Stream<List<Report>> getReports({bool includeAll = false}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query = firestore.collection('reports');
    if (!includeAll) {
      query = query.where('reporterUid', isEqualTo: user.uid);
    }

    return query.snapshots().map((snapshot) {

      final reports = snapshot.docs.map((doc) {

        return Report.fromMap(doc.id, doc.data());

      }).toList();

      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    String? assignedCounsellorUid,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
      };

      if (assignedCounsellorUid != null && assignedCounsellorUid.isNotEmpty) {
        data['assignedCounsellorUid'] = assignedCounsellorUid;
      }

      await firestore.collection('reports').doc(reportId).update(data);
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown error';
      throw Exception('Update report status failed [${e.code}]: $message');
    }
  }

  Future<void> updateReport({
    required String reportId,
    required String reporterUid,
    required String title,
    required String category,
    required String tag,
    required DateTime dateTime,
    required String location,
    required String description,
    required String status,
    required String? assignedCounsellorUid,
    required DateTime createdAt,
    required List<Map<String, dynamic>> attachments,
  }) async {
    try {
      await firestore.collection('reports').doc(reportId).update({
        'reporterUid': reporterUid,
        'title': title,
        'category': category,
        'tag': tag,
        'dateTime': dateTime,
        'location': location,
        'description': description,
        'status': status,
        'assignedCounsellorUid': assignedCounsellorUid,
        'createdAt': createdAt,
        'attachments': attachments,
      });
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown error';
      throw Exception('Update report failed [${e.code}]: $message');
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await firestore.collection('reports').doc(reportId).delete();
    } on FirebaseException catch (e) {
      final message = e.message ?? 'Unknown error';
      throw Exception('Delete report failed [${e.code}]: $message');
    }
  }

  Stream<ReportDashboardStats> watchDashboardStats() {
    return getReports(includeAll: true).asyncMap(_buildStats);
  }

  Future<ReportDashboardStats> _buildStats(List<Report> reports) async {
    if (reports.isEmpty) {
      return ReportDashboardStats.empty;
    }

    final Map<String, int> categoryCounts = <String, int>{};
    final Map<String, int> facultyCounts = <String, int>{};
    final Map<String, int> statusCounts = <String, int>{};

    for (final report in reports) {
      final category = report.category.trim().isEmpty ? 'Uncategorized' : report.category.trim();
      final status = report.status.trim().isEmpty ? 'new' : report.status.trim();
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    final reporterUids = reports.map((r) => r.reporterUid).toSet().toList();
    final facultyByUid = await _loadFacultyMap(reporterUids);

    for (final report in reports) {
      final faculty = (facultyByUid[report.reporterUid] ?? 'Unknown Faculty').trim();
      final key = faculty.isEmpty ? 'Unknown Faculty' : faculty;
      facultyCounts[key] = (facultyCounts[key] ?? 0) + 1;
    }

    return ReportDashboardStats(
      totalReports: reports.length,
      categoryCounts: categoryCounts,
      facultyCounts: facultyCounts,
      statusCounts: statusCounts,
    );
  }

  Future<Map<String, String>> _loadFacultyMap(List<String> uids) async {
    if (uids.isEmpty) {
      return <String, String>{};
    }

    final futures = uids.map((uid) => firestore.collection('users').doc(uid).get());
    final docs = await Future.wait(futures);

    final result = <String, String>{};
    for (final doc in docs) {
      final data = doc.data();
      if (data == null) {
        continue;
      }

      result[doc.id] = (data['faculty'] ?? '').toString();
    }

    return result;
  }
}