import 'package:flutter/material.dart';
import '../controllers/report_controller.dart';
import '../models/report_model.dart';
import '../widgets/counsellor_report_card.dart';
import '../widgets/report_card.dart';
import '../style/style.dart';

class RecordsPage extends StatelessWidget {
  final bool isCounsellor;

  const RecordsPage({
    super.key,
    required this.isCounsellor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Incident Report Records",
          style: CustomStyle.h3,
        ),
      ),
      body: RecordsListSection(isCounsellor: isCounsellor),
    );
  }
}

class RecordsListSection extends StatelessWidget {
  final bool isCounsellor;

  const RecordsListSection({
    super.key,
    required this.isCounsellor,
  });

  @override
  Widget build(BuildContext context) {
    final ReportController controller = ReportController();

    return StreamBuilder<List<Report>>(
      stream: controller.getReports(includeAll: isCounsellor),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Failed to load reports: ${snapshot.error}"),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No reports found"),
          );
        }

        final reports = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            if (isCounsellor) {
              return CounsellorReportCard(
                report: reports[index],
                controller: controller,
              );
            }

            return ReportCard(
              report: reports[index],
              controller: controller,
            );
          },
        );
      },
    );
  }
}
