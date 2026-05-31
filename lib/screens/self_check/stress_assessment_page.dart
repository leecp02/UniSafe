import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/self_check_models.dart';
import '../../services/self_check_service.dart';
import '../../widgets/self_check_common_widgets.dart';
import '../self_check_page.dart';

class StressAssessmentPage extends StatefulWidget {
  const StressAssessmentPage({super.key});

  @override
  State<StressAssessmentPage> createState() => _StressAssessmentPageState();
}

class _StressAssessmentPageState extends State<StressAssessmentPage> {
  static const List<StressQuestion> _questions = <StressQuestion>[
    StressQuestion('Work & Time Pressure', 'I often bring work or responsibilities into my personal time.'),
    StressQuestion('Work & Time Pressure', 'I feel there are not enough hours in the day to finish everything.'),
    StressQuestion('Work & Time Pressure', 'I avoid or ignore problems hoping they will go away.'),
    StressQuestion('Work & Time Pressure', 'I prefer doing tasks myself to make sure they are done properly.'),
    StressQuestion('Work & Time Pressure', 'I underestimate how long tasks will take.'),
    StressQuestion('Work & Time Pressure', 'I feel overwhelmed by deadlines or responsibilities.'),
    StressQuestion('Thoughts & Emotions', 'I feel my self-confidence is lower than I would like.'),
    StressQuestion('Thoughts & Emotions', 'I feel guilty when I take time to relax.'),
    StressQuestion('Thoughts & Emotions', 'I think about problems even when trying to rest.'),
    StressQuestion('Thoughts & Emotions', 'I feel tired even after getting enough sleep.'),
    StressQuestion('Behavior Patterns', 'I get impatient when others are slow.'),
    StressQuestion('Behavior Patterns', 'I tend to do things quickly (eating, walking, talking).'),
    StressQuestion('Behavior Patterns', 'My eating habits have changed (overeating or skipping meals).'),
    StressQuestion('Behavior Patterns', 'I feel easily irritated (in traffic or waiting situations).'),
    StressQuestion('Behavior Patterns', 'I keep my feelings inside instead of expressing them.'),
    StressQuestion('Performance & Social', 'I feel strong pressure to win or succeed in everything I do.'),
    StressQuestion('Performance & Social', 'I experience mood swings or difficulty focusing.'),
    StressQuestion('Performance & Social', 'I criticize others more than I praise them.'),
    StressQuestion('Performance & Social', 'I appear to listen but my mind is elsewhere.'),
    StressQuestion('Physical & Lifestyle', 'I have noticed changes in personal or physical well-being (low energy or routine changes).'),
    StressQuestion('Physical & Lifestyle', 'I experience physical tension (headaches, muscle pain, jaw clenching).'),
    StressQuestion('Physical & Lifestyle', 'I feel my performance or decision-making is not as good as before.'),
    StressQuestion('Physical & Lifestyle', 'I rely more on substances (for example, caffeine) to cope.'),
    StressQuestion('Physical & Lifestyle', 'I have less time for hobbies or activities I enjoy.'),
  ];

  final SelfCheckService _service = SelfCheckService();
  final List<bool?> _answers = List<bool?>.filled(_questions.length, null);
  bool _isSubmitting = false;

  bool get _isComplete => _answers.every((answer) => answer != null);
  int get _score => _answers.where((answer) => answer == true).length;
  StressLevel get _stressLevel => stressLevelFromScore(_score);

  List<String> get _suggestions {
    final Map<String, int> groupCount = <String, int>{};
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == true) {
        final group = _questions[i].group;
        groupCount[group] = (groupCount[group] ?? 0) + 1;
      }
    }

    final rankedGroups = groupCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final feedback = <String>[];
    for (final entry in rankedGroups.take(3)) {
      switch (entry.key) {
        case 'Work & Time Pressure':
          feedback.add('Try breaking tasks into smaller steps and set realistic deadlines.');
          break;
        case 'Physical & Lifestyle':
          feedback.add('Prioritize rest, hydration, and light stretching; seek professional support if symptoms continue.');
          break;
        case 'Thoughts & Emotions':
          feedback.add('Set short worry breaks and practice calming routines before sleep.');
          break;
        case 'Behavior Patterns':
          feedback.add('Pause before reacting and use slower pacing for routine activities.');
          break;
        case 'Performance & Social':
          feedback.add('Set boundaries on performance pressure and check in with someone you trust.');
          break;
      }
    }

    if (feedback.isEmpty) {
      return <String>['Keep your current healthy routine and continue regular self-checks.'];
    }
    return feedback;
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
      await _service.addStressAssessment(
        uid: user.uid,
        answers: _answers.map((value) => value == true).toList(),
        score: _score,
        riskStatus: _stressLevel.label,
        resultMessage: _stressLevel.message,
        suggestions: _suggestions,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stress assessment submitted successfully.')),
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
        const SnackBar(content: Text('Failed to submit stress assessment.')),
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
    String currentGroup = '';

    return Scaffold(
      appBar: AppBar(title: const Text('Stress Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Daily Stress Habits',
              instruction: 'In the past few weeks, how often have you experienced the following? (Yes / No)',
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _questions.length; i++) ...[
              if (_questions[i].group != currentGroup) ...[
                Builder(
                  builder: (_) {
                    currentGroup = _questions[i].group;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 6),
                      child: Text(
                        _questions[i].group,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    );
                  },
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: YesNoTile(
                  number: i + 1,
                  text: _questions[i].text,
                  value: _answers[i],
                  onChanged: (value) {
                    setState(() {
                      _answers[i] = value;
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            StressResultCard(score: _score, level: _stressLevel, suggestions: _suggestions),
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

class StressResultCard extends StatelessWidget {
  const StressResultCard({super.key, required this.score, required this.level, required this.suggestions});

  final int score;
  final StressLevel level;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stress Examination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TriggerRow(label: 'Total score', value: '$score / 24'),
            const SizedBox(height: 12),
            StatusPanel(
              label: level.label,
              message: level.message,
              color: level.color,
              emoji: level == StressLevel.low ? '🟢' : level == StressLevel.moderate ? '🟡' : '🔴',
            ),
            const SizedBox(height: 10),
            const Text('Suggested actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            ...suggestions.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('- $item', style: const TextStyle(fontSize: 12.5)),
                )),
          ],
        ),
      ),
    );
  }
}
