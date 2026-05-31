import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/self_check/check_record_detail_pages.dart';
import '../services/self_check_service.dart';

class CheckTrendCarousel extends StatefulWidget {
  const CheckTrendCarousel({super.key});

  @override
  State<CheckTrendCarousel> createState() => _CheckTrendCarouselState();
}

class _CheckTrendCarouselState extends State<CheckTrendCarousel> {
  late ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateArrows);
    
    // Check if there's enough content to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrows();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 0;
      _showRightArrow = 
          _scrollController.offset < _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 350,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 350,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Check Trends',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    _TrendCard(
                      title: 'Mood Check',
                      subtitle: 'Risk score progression',
                      child: const MoodTrendChart(),
                    ),
                    const SizedBox(width: 12),
                    _TrendCard(
                      title: 'Stress Check',
                      subtitle: 'Score progression',
                      child: const StressTrendChart(),
                    ),
                    const SizedBox(width: 12),
                    _TrendCard(
                      title: 'Wellbeing Check',
                      subtitle: 'Score progression',
                      child: const WellbeingTrendChart(),
                    ),
                  ],
                ),
              ),
            ),
            // Left scroll indicator arrow
            if (_showLeftArrow)
              Positioned(
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _scrollLeft,
                    tooltip: 'Scroll left',
                  ),
                ),
              ),
            // Right scroll indicator arrow
            if (_showRightArrow)
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _scrollRight,
                    tooltip: 'Scroll right',
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 340,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CheckNowCard extends StatelessWidget {
  const CheckNowCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_circle_fill_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text(
                      'Tap to open the three self-check categories and start a guided assessment.',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key});

  static const List<String> _months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const List<int> _scores = <int>[35, 45, 42, 58, 65, 71];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mood Check risk score by month (0-100)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(scores: _scores, lineColor: Colors.orange, fillColor: Colors.orange),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            _months.length,
            (index) => Text(_months[index], style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class StressTrendChart extends StatelessWidget {
  const StressTrendChart({super.key});

  static const List<String> _months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const List<int> _scores = <int>[8, 12, 10, 15, 14, 11];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stress Check score by month (0-24)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(
              scores: _scores.map((s) => (s / 24 * 100).toInt()).toList(),
              lineColor: Colors.red,
              fillColor: Colors.red,
              maxValue: 24,
              displayScores: _scores,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            _months.length,
            (index) => Text(_months[index], style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class WellbeingTrendChart extends StatelessWidget {
  const WellbeingTrendChart({super.key});

  static const List<String> _months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const List<int> _scores = <int>[55, 62, 60, 72, 78, 75];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Wellbeing Check score by month (0-100)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _TrendChartPainter(scores: _scores, lineColor: Colors.green, fillColor: Colors.green),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(
            _months.length,
            (index) => Text(_months[index], style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.scores,
    this.lineColor = Colors.blue,
    this.fillColor = Colors.blue,
    this.maxValue = 100,
    this.displayScores,
  });

  final List<int> scores;
  final Color lineColor;
  final Color fillColor;
  final int maxValue;
  final List<int>? displayScores;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) {
      return;
    }

    const chartMin = 0;
    const chartMax = 100;

    final gridPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 1;

    for (var i = 1; i <= 3; i++) {
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor.withOpacity(0.22), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final points = <Offset>[];
    for (var index = 0; index < scores.length; index++) {
      final x = scores.length == 1 ? size.width / 2 : size.width * index / (scores.length - 1);
      final normalized = (scores[index].clamp(chartMin, chartMax) - chartMin) / (chartMax - chartMin);
      final y = size.height - (normalized * (size.height - 24)) - 8;
      points.add(Offset(x, y));
    }

    final areaPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      areaPath.lineTo(point.dx, point.dy);
    }
    areaPath.lineTo(points.last.dx, size.height);
    areaPath.close();
    canvas.drawPath(areaPath, fillPaint);

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      linePath.lineTo(points[index].dx, points[index].dy);
    }
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      canvas.drawCircle(point, 4.5, dotPaint);

      // Use displayScores if provided (for stress chart), otherwise use scores
      final displayValue = displayScores?[index] ?? scores[index];
      final labelPainter = TextPainter(
        text: TextSpan(
          text: displayValue.toString(),
          style: TextStyle(color: lineColor, fontSize: 11, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final dx = point.dx - labelPainter.width / 2;
      final dy = (point.dy - 18).clamp(0, size.height - labelPainter.height).toDouble();
      labelPainter.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => 
      oldDelegate.scores != scores || 
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor;
}

class CheckHistoryList extends StatelessWidget {
  CheckHistoryList({super.key});

  final SelfCheckService _service = SelfCheckService();

  Future<void> _confirmAndDelete(
    BuildContext context, {
    required String uid,
    required String assessmentId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this history record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _service.deleteAssessment(uid: uid, assessmentId: assessmentId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('History record deleted.')),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete record.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text('Sign in to view your check history.', style: TextStyle(fontSize: 13, color: Colors.black54));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.watchAssessments(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Unable to load history right now.', style: TextStyle(fontSize: 13, color: Colors.black54));
        }

        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Text(
            'No check records yet. Submit a test to create your first record.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final String result = (data['riskStatus'] as String?) ?? (((data['positiveScreen'] as bool?) ?? false) ? 'Positive' : 'Negative');
            final String category = (data['category'] as String?) ?? 'Mood Check';
            final Timestamp? ts = data['createdAt'] as Timestamp?;
            final dateText = ts == null ? 'Date not available' : formatSelfCheckDateTime(ts.toDate());
            final type = (data['assessmentType'] as String?) ?? ((category == 'Stress Check') ? 'stress' : 'mdq');

            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined, size: 20),
              title: Text(result),
              subtitle: Text('$category • $dateText'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Delete record',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      _confirmAndDelete(
                        context,
                        uid: user.uid,
                        assessmentId: doc.id,
                      );
                    },
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => type == 'stress'
                        ? StressRecordDetailPage(record: data)
                        : type == 'wellbeing'
                            ? WellbeingRecordDetailPage(record: data)
                            : MdqRecordDetailPage(record: data),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
