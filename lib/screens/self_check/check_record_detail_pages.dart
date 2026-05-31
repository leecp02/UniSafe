import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/self_check_models.dart';
import 'mdq_assessment_page.dart';
import 'stress_assessment_page.dart';
import 'wellbeing_assessment_page.dart';

String formatSelfCheckDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}

class MdqRecordDetailPage extends StatelessWidget {
  const MdqRecordDetailPage({super.key, required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final String category = (record['category'] as String?) ?? 'Mood Check';
    final Timestamp? createdAt = record['createdAt'] as Timestamp?;
    final int rawScore = (record['rawScore'] as num?)?.toInt() ?? 0;
    final double endorsementPercent = (record['endorsementPercent'] as num?)?.toDouble() ?? 0;
    final bool? timingClustered = record['timingClustered'] as bool?;
    final bool positiveScreen = (record['positiveScreen'] as bool?) ?? false;

    final String impactText = (record['impact'] as String?) ?? ImpactLevel.noImpact.label;
    final ImpactLevel impactLevel = impactLevelFromLabel(impactText);

    final positiveMap = (record['positiveActivation'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final negativeMap = (record['negativeActivation'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    final int positiveActivationCount = (positiveMap['score'] as num?)?.toInt() ?? 0;
    final int negativeActivationCount = (negativeMap['score'] as num?)?.toInt() ?? 0;

    final String riskText = (record['riskStatus'] as String?) ?? RiskStatus.lowRisk.label;
    final RiskStatus riskStatus = riskStatusFromLabel(riskText);

    return Scaffold(
      appBar: AppBar(title: const Text('Examination Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Category: $category', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            createdAt == null ? 'Submitted: Date not available' : 'Submitted: ${formatSelfCheckDateTime(createdAt.toDate())}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          MdqResultCard(
            rawScore: rawScore,
            endorsementPercent: endorsementPercent,
            timingClustered: timingClustered,
            impactLevel: impactLevel,
            positiveScreen: positiveScreen,
            positiveActivationCount: positiveActivationCount,
            negativeActivationCount: negativeActivationCount,
            riskStatus: riskStatus,
          ),
        ],
      ),
    );
  }
}

class StressRecordDetailPage extends StatelessWidget {
  const StressRecordDetailPage({super.key, required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final String category = (record['category'] as String?) ?? 'Stress Check';
    final Timestamp? createdAt = record['createdAt'] as Timestamp?;
    final int score = (record['score'] as num?)?.toInt() ?? 0;
    final String statusText = (record['riskStatus'] as String?) ?? StressLevel.low.label;
    final StressLevel level = stressLevelFromLabel(statusText);

    final List<dynamic> suggestionsRaw = (record['suggestions'] as List<dynamic>?) ?? const <dynamic>[];
    final List<String> suggestions = suggestionsRaw.map((e) => e.toString()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Examination Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Category: $category', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            createdAt == null ? 'Submitted: Date not available' : 'Submitted: ${formatSelfCheckDateTime(createdAt.toDate())}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          StressResultCard(score: score, level: level, suggestions: suggestions),
        ],
      ),
    );
  }
}

class WellbeingRecordDetailPage extends StatelessWidget {
  const WellbeingRecordDetailPage({super.key, required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final Timestamp? createdAt = record['createdAt'] as Timestamp?;
    final int overallScore = (record['overallScore'] as num?)?.toInt() ?? 0;
    final int concernScore = (record['concernScore'] as num?)?.toInt() ?? 0;
    final int protectiveScore = (record['protectiveScore'] as num?)?.toInt() ?? 0;
    final int emotionScore = (record['emotionScore'] as num?)?.toInt() ?? 0;
    final int behaviorScore = (record['behaviorScore'] as num?)?.toInt() ?? 0;
    final int supportScore = (record['supportScore'] as num?)?.toInt() ?? 0;
    final int strengthScore = (record['strengthScore'] as num?)?.toInt() ?? 0;
    final int lifeScore = (record['lifeScore'] as num?)?.toInt() ?? 0;
    final int finalAdjustment = (record['finalAdjustment'] as num?)?.toInt() ?? 0;

    final String riskText = (record['riskStatus'] as String?) ?? WellbeingStatus.moderate.label;
    final WellbeingStatus status = wellbeingStatusFromLabel(riskText);

    final List<dynamic> focusRaw = (record['focusAreas'] as List<dynamic>?) ?? const <dynamic>[];
    final List<String> focusAreas = focusRaw.map((e) => e.toString()).toList();
    final List<dynamic> suggestionRaw = (record['suggestions'] as List<dynamic>?) ?? const <dynamic>[];
    final List<String> suggestions = suggestionRaw.map((e) => e.toString()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Examination Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Category: ${(record['category'] as String?) ?? 'Wellbeing Check'}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            createdAt == null ? 'Submitted: Date not available' : 'Submitted: ${formatSelfCheckDateTime(createdAt.toDate())}',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          WellbeingResultCard(
            status: status,
            overallScore: overallScore,
            concernScore: concernScore,
            protectiveScore: protectiveScore,
            emotionScore: emotionScore,
            behaviorScore: behaviorScore,
            supportScore: supportScore,
            strengthScore: strengthScore,
            lifeScore: lifeScore,
            finalAdjustment: finalAdjustment,
            suggestions: suggestions,
            focusAreas: focusAreas,
          ),
        ],
      ),
    );
  }
}
