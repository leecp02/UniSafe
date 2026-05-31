import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/self_check_models.dart';
import '../../services/self_check_service.dart';
import '../../widgets/self_check_common_widgets.dart';
import '../self_check_page.dart';

class MdqAssessmentPage extends StatefulWidget {
  const MdqAssessmentPage({
    super.key,
    required this.categoryLabel,
  });

  final String categoryLabel;

  @override
  State<MdqAssessmentPage> createState() => _MdqAssessmentPageState();
}

class _MdqAssessmentPageState extends State<MdqAssessmentPage> {
  static const List<String> _symptomItems = <String>[
    'I felt unusually happy, excited, or high compared to my normal self.',
    'I felt more irritable than usual (easily annoyed or arguing with others).',
    'I felt more confident or powerful than usual.',
    'I needed less sleep but still felt energetic.',
    'I talked more or faster than usual.',
    'My thoughts were racing or hard to control.',
    'I had trouble focusing because I was easily distracted.',
    'I had much more energy than usual.',
    'I was more active or productive than usual.',
    'I was more social than usual (messaging or calling a lot).',
    'I had a stronger interest in romantic or personal relationships than usual.',
    'I did things that felt unusual, risky, or out of character.',
    'I spent more money than usual or made impulsive decisions.',
  ];

  final SelfCheckService _service = SelfCheckService();
  final List<bool?> _answers = List<bool?>.filled(13, null);
  bool? _timingClustered;
  ImpactLevel _impactLevel = ImpactLevel.noImpact;
  bool _isSubmitting = false;

  int get _rawScore => _answers.where((answer) => answer == true).length;
  double get _endorsementPercent => (_rawScore / _answers.length) * 100;
  bool get _areSymptomsCompleted => _answers.every((answer) => answer != null);

  int get _positiveActivationCount {
    const indices = <int>[2, 3, 7, 8];
    return indices.where((index) => _answers[index] == true).length;
  }

  int get _negativeActivationCount {
    const indices = <int>[0, 1, 5, 6, 11, 12];
    return indices.where((index) => _answers[index] == true).length;
  }

  bool get _requiresTimingAnswer => _rawScore > 1;
  bool get _isComplete => _areSymptomsCompleted && (!_requiresTimingAnswer || _timingClustered != null);

  bool get _positiveScreen {
    final hasImpact = _impactLevel == ImpactLevel.moderateImpact || _impactLevel == ImpactLevel.seriousImpact;
    return _rawScore >= 7 && (_timingClustered == true) && hasImpact;
  }

  RiskStatus get _riskStatus {
    if (_positiveScreen || _negativeActivationCount >= 4 || _rawScore >= 9) {
      return RiskStatus.needsSupport;
    }
    if (_rawScore >= 3 || _positiveActivationCount >= 2 || _negativeActivationCount >= 2) {
      return RiskStatus.monitor;
    }
    return RiskStatus.lowRisk;
  }

  Future<void> _submitAssessment() async {
    if (!_isComplete || _isSubmitting) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in before submitting your test.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _service.addMdqAssessment(
        uid: user.uid,
        category: widget.categoryLabel,
        answers: _answers.map((value) => value == true).toList(),
        timingClustered: _timingClustered ?? false,
        impact: _impactLevel.label,
        rawScore: _rawScore,
        endorsementPercent: _endorsementPercent,
        positiveScreen: _positiveScreen,
        positiveActivation: _positiveActivationCount,
        negativeActivation: _negativeActivationCount,
        riskStatus: _riskStatus.label,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assessment submitted and saved successfully.')),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SelfCheckPage()),
        (route) => route.isFirst,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit assessment. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryLabel} (MDQ)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Section 1: Mood & Behavior Changes',
              instruction: 'In the past few weeks, have you experienced any of the following?',
            ),
            const SizedBox(height: 8),
            for (int index = 0; index < _symptomItems.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: YesNoTile(
                  number: index + 1,
                  text: _symptomItems[index],
                  value: _answers[index],
                  onChanged: (value) {
                    setState(() {
                      _answers[index] = value;
                    });
                  },
                ),
              ),
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Section 2: Timing',
              instruction: 'If you answered Yes to more than one item above:',
            ),
            const SizedBox(height: 8),
            YesNoTile(
              number: null,
              text: 'Did several of these happen during the same time period?',
              value: _timingClustered,
              onChanged: _requiresTimingAnswer
                  ? (value) {
                      setState(() {
                        _timingClustered = value;
                      });
                    }
                  : null,
            ),
            if (!_requiresTimingAnswer)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Answer Yes to at least two symptom items to enable this question.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 18),
            const SectionHeader(
              title: 'Section 3: Impact',
              instruction: 'How much did these experiences affect your daily life?',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: ImpactLevel.values
                      .map(
                        (level) => RadioListTile<ImpactLevel>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(level.label),
                          value: level,
                          groupValue: _impactLevel,
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _impactLevel = value;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            MdqResultCard(
              rawScore: _rawScore,
              endorsementPercent: _endorsementPercent,
              timingClustered: _timingClustered,
              impactLevel: _impactLevel,
              positiveScreen: _positiveScreen,
              positiveActivationCount: _positiveActivationCount,
              negativeActivationCount: _negativeActivationCount,
              riskStatus: _riskStatus,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isComplete && !_isSubmitting ? _submitAssessment : null,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MdqResultCard extends StatelessWidget {
  const MdqResultCard({
    super.key,
    required this.rawScore,
    required this.endorsementPercent,
    required this.timingClustered,
    required this.impactLevel,
    required this.positiveScreen,
    required this.positiveActivationCount,
    required this.negativeActivationCount,
    required this.riskStatus,
  });

  final int rawScore;
  final double endorsementPercent;
  final bool? timingClustered;
  final ImpactLevel impactLevel;
  final bool positiveScreen;
  final int positiveActivationCount;
  final int negativeActivationCount;
  final RiskStatus riskStatus;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = positiveScreen ? Colors.red.shade700 : Colors.green.shade700;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MDQ Examination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TriggerRow(label: 'Q1-13 raw score', value: '$rawScore / 13'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Endorsed percentage', value: '${endorsementPercent.toStringAsFixed(1)}%'),
            const SizedBox(height: 5),
            TriggerRow(
              label: 'Timing clustered',
              value: timingClustered == null ? 'Not answered' : (timingClustered! ? 'Yes' : 'No'),
            ),
            const SizedBox(height: 5),
            TriggerRow(label: 'Impact', value: impactLevel.label),
            const SizedBox(height: 8),
            Text(
              positiveScreen ? 'Screening result: Positive (criteria met)' : 'Screening result: Negative (criteria not met)',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            const Text('Subscale scores', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TriggerRow(
              label: 'Positive Activation',
              value: '$positiveActivationCount / 4 (${(positiveActivationCount / 4 * 100).toStringAsFixed(0)}%)',
            ),
            const SizedBox(height: 4),
            const Text(
              'Interpretation: High = energetic, active, confident. Low = normal baseline.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 5),
            TriggerRow(
              label: 'Negative Activation',
              value: '$negativeActivationCount / 6 (${(negativeActivationCount / 6 * 100).toStringAsFixed(0)}%)',
            ),
            const SizedBox(height: 4),
            const Text(
              'Interpretation: High = irritability, stress, emotional instability; useful for detecting distress or risk behavior.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.35),
            ),
            const SizedBox(height: 10),
            StatusPanel(
              label: riskStatus.label,
              message: riskStatus.message,
              color: riskStatus.color,
              emoji: riskStatus == RiskStatus.lowRisk ? '🟢' : riskStatus == RiskStatus.monitor ? '🟡' : '🔴',
            ),
          ],
        ),
      ),
    );
  }
}
