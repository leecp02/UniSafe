import 'package:flutter/material.dart';

enum ImpactLevel {
  noImpact('No impact'),
  slightImpact('Slight impact'),
  moderateImpact('Moderate impact'),
  seriousImpact('Serious impact');

  const ImpactLevel(this.label);
  final String label;
}

ImpactLevel impactLevelFromLabel(String label) {
  for (final level in ImpactLevel.values) {
    if (level.label == label) {
      return level;
    }
  }
  return ImpactLevel.noImpact;
}

enum RiskStatus {
  lowRisk(
    'Low Risk',
    'Your responses show no significant mood changes. Keep maintaining your well-being.',
    Color(0xFF2E7D32),
  ),
  monitor(
    'Monitor',
    'You have reported some mood changes. Consider monitoring your feelings and talking to someone you trust.',
    Color(0xFFF9A825),
  ),
  needsSupport(
    'Needs Support',
    'Your responses suggest significant mood and behavior changes. You may benefit from speaking to a counselor or using support services.',
    Color(0xFFC62828),
  );

  const RiskStatus(this.label, this.message, this.color);
  final String label;
  final String message;
  final Color color;
}

RiskStatus riskStatusFromLabel(String label) {
  for (final status in RiskStatus.values) {
    if (status.label == label) {
      return status;
    }
  }
  return RiskStatus.lowRisk;
}

enum StressLevel {
  low(
    'Low Stress',
    'You are currently managing stress well. Keep maintaining a healthy balance.',
    Color(0xFF2E7D32),
  ),
  moderate(
    'Moderate Stress',
    'You may be experiencing some stress. Consider small changes or talking to someone you trust.',
    Color(0xFFF9A825),
  ),
  high(
    'High Stress',
    'You are experiencing high levels of stress. Please consider submitting a report to talk to a counselor, or seek helps from the hotline services.',
    Color(0xFFC62828),
  );

  const StressLevel(this.label, this.message, this.color);
  final String label;
  final String message;
  final Color color;
}

StressLevel stressLevelFromScore(int score) {
  if (score >= 14) {
    return StressLevel.high;
  }
  if (score >= 5) {
    return StressLevel.moderate;
  }
  return StressLevel.low;
}

StressLevel stressLevelFromLabel(String label) {
  for (final level in StressLevel.values) {
    if (level.label == label) {
      return level;
    }
  }
  return StressLevel.low;
}

enum WellbeingStatus {
  good(
    'Good Wellbeing',
    'Balanced emotions + good support.',
    Color(0xFF2E7D32),
  ),
  moderate(
    'Moderate Wellbeing',
    'Some stress or emotional concerns.',
    Color(0xFFF9A825),
  ),
  low(
    'Low Wellbeing',
    'Signs of distress + low support.',
    Color(0xFFC62828),
  );

  const WellbeingStatus(this.label, this.message, this.color);
  final String label;
  final String message;
  final Color color;
}

WellbeingStatus wellbeingStatusFromLabel(String label) {
  for (final status in WellbeingStatus.values) {
    if (status.label == label) {
      return status;
    }
  }
  return WellbeingStatus.moderate;
}

class ScaleLabel {
  const ScaleLabel(this.label, this.value);
  final String label;
  final int value;
}

class QuestionItem {
  const QuestionItem(this.text, {this.reverseScored = false});
  final String text;
  final bool reverseScored;
}

class GroupedQuestionItem {
  const GroupedQuestionItem(this.group, this.text);
  final String group;
  final String text;
}

class ChoiceOption {
  const ChoiceOption({required this.label, required this.value});
  final String label;
  final int value;
}

class StressQuestion {
  const StressQuestion(this.group, this.text);
  final String group;
  final String text;
}
