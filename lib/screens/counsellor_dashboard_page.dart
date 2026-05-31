import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../controllers/report_controller.dart';
import '../models/report_dashboard_stats_model.dart';
import '../style/style.dart';

class CounsellorDashboardPage extends StatelessWidget {
  const CounsellorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportController reportController = ReportController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<ReportDashboardStats>(
        stream: reportController.watchDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load statistics: ${snapshot.error}'),
            );
          }

          final stats = snapshot.data ?? ReportDashboardStats.empty;

          if (stats.totalReports == 0) {
            return const Center(
              child: Text('No submitted reports yet.'),
            );
          }

          return ListView(
            children: [
              Text('Report Statistics', style: CustomStyle.h3),
              const SizedBox(height: 12),
              _SummaryTile(
                title: 'Total Submitted Reports',
                value: stats.totalReports.toString(),
                icon: Icons.summarize_outlined,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 700) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PieChartCard(
                            title: 'Status Distribution',
                            values: stats.statusCounts,
                            icon: Icons.pie_chart_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BarChartCard(
                            title: 'Reports by Category',
                            values: stats.categoryCounts,
                            icon: Icons.bar_chart_outlined,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      _PieChartCard(
                        title: 'Status Distribution',
                        values: stats.statusCounts,
                        icon: Icons.pie_chart_outline,
                      ),
                      const SizedBox(height: 12),
                      _BarChartCard(
                        title: 'Reports by Category',
                        values: stats.categoryCounts,
                        icon: Icons.bar_chart_outlined,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _BreakdownCard(
                title: 'Reports by Faculty',
                values: stats.facultyCounts,
                icon: Icons.school_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> values;
  final IconData icon;

  const _PieChartCard({
    required this.title,
    required this.values,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CustomStyle.primary),
              const SizedBox(width: 8),
              Text(title, style: CustomStyle.h5),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty || total == 0)
            Text('No data yet', style: CustomStyle.subtitle)
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _PieChartPainter(entries: entries),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...entries.take(4).map((entry) {
                        final percentage = (entry.value / total) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: _PieChartPainter.colorForIndex(
                                    entries.indexOf(entry),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key} (${percentage.toStringAsFixed(0)}%)',
                                  style: CustomStyle.txt,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;

  _PieChartPainter({required this.entries});

  static const List<Color> _palette = [
    Color(0xFF6C63FF),
    Color(0xFF3F8EFC),
    Color(0xFF4CAF50),
    Color(0xFFFFB74D),
    Color(0xFFE57373),
    Color(0xFF26A69A),
  ];

  static Color colorForIndex(int index) {
    return _palette[index % _palette.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    if (total == 0) {
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    var startAngle = -math.pi / 2;
    for (var i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) * math.pi * 2;
      final paint = Paint()
        ..color = colorForIndex(i)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    final holePaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.55, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: CustomStyle.primary.withOpacity(0.15),
            child: Icon(icon, color: CustomStyle.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CustomStyle.h5),
                const SizedBox(height: 4),
                Text(value, style: CustomStyle.h2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final String title;
  final Map<String, int> values;
  final IconData icon;

  const _BreakdownCard({
    required this.title,
    required this.values,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxValue = sortedEntries.isEmpty
        ? 1
        : sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CustomStyle.primary),
              const SizedBox(width: 8),
              Text(title, style: CustomStyle.h5),
            ],
          ),
          const SizedBox(height: 10),
          if (sortedEntries.isEmpty)
            Text('No data yet', style: CustomStyle.subtitle)
          else
            ...sortedEntries.map((entry) {
              final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomStyle.txt,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: ratio,
                          backgroundColor: Colors.grey.shade300,
                          color: CustomStyle.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 28,
                      child: Text(
                        entry.value.toString(),
                        textAlign: TextAlign.right,
                        style: CustomStyle.h5,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final Map<String, int> values;
  final IconData icon;

  const _BarChartCard({
    required this.title,
    required this.values,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = entries.isEmpty ? 1 : entries.first.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CustomStyle.primary),
              const SizedBox(width: 8),
              Text(title, style: CustomStyle.h5),
            ],
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text('No data yet', style: CustomStyle.subtitle)
          else
            ...entries.take(6).map((entry) {
              final ratio = maxValue == 0 ? 0.0 : entry.value / maxValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CustomStyle.txt,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(entry.value.toString(), style: CustomStyle.h5),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: ratio,
                        backgroundColor: Colors.grey.shade300,
                        color: CustomStyle.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
