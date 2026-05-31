import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/self_check_models.dart';
import '../../services/self_check_service.dart';
import '../../widgets/self_check_common_widgets.dart';
import '../self_check_page.dart';

class WellbeingAssessmentPage extends StatefulWidget {
  const WellbeingAssessmentPage({super.key});

  @override
  State<WellbeingAssessmentPage> createState() => _WellbeingAssessmentPageState();
}

class _WellbeingAssessmentPageState extends State<WellbeingAssessmentPage> {
  final PageController _pageController = PageController();
  final SelfCheckService _service = SelfCheckService();

  final List<int?> _emotionAnswers = List<int?>.filled(6, null);
  final List<int?> _behaviorAnswers = List<int?>.filled(6, null);
  final List<int?> _supportAnswers = List<int?>.filled(9, null);
  final List<int?> _strengthAnswers = List<int?>.filled(6, null);
  final List<int?> _lifeAnswers = List<int?>.filled(5, null);
  int? _finalAnswer;
  int _pageIndex = 0;
  bool _isSubmitting = false;

  static const List<ScaleLabel> _threePointScale = <ScaleLabel>[
    ScaleLabel('Never', 0),
    ScaleLabel('Sometimes', 1),
    ScaleLabel('Always', 2),
  ];

  static const List<ScaleLabel> _fivePointScale = <ScaleLabel>[
    ScaleLabel('Strongly Disagree', 0),
    ScaleLabel('Disagree', 1),
    ScaleLabel('Neutral', 2),
    ScaleLabel('Agree', 3),
    ScaleLabel('Strongly Agree', 4),
  ];

  static const List<ScaleLabel> _finalScale = <ScaleLabel>[
    ScaleLabel('No change', 0),
    ScaleLabel('I feel happier', 1),
    ScaleLabel('I feel a bit worse', 2),
  ];

  static const List<QuestionItem> _emotions = <QuestionItem>[
    QuestionItem('I feel lonely'),
    QuestionItem('I feel sad or unhappy'),
    QuestionItem('I cry often'),
    QuestionItem('I worry a lot'),
    QuestionItem('I feel scared or anxious'),
    QuestionItem('I feel nervous in certain places (e.g., school/work)'),
  ];

  static const List<QuestionItem> _behaviour = <QuestionItem>[
    QuestionItem('I have trouble sleeping or wake up at night'),
    QuestionItem('I get angry easily'),
    QuestionItem('I lose my temper'),
    QuestionItem('I act in ways that may hurt others'),
    QuestionItem('I feel calm and in control', reverseScored: true),
    QuestionItem('I get frustrated easily (e.g., waiting, slow situations)'),
  ];

  static const List<GroupedQuestionItem> _support = <GroupedQuestionItem>[
    GroupedQuestionItem('At School / Work', 'There is an adult who cares about me'),
    GroupedQuestionItem('At School / Work', 'Someone encourages me when I do well'),
    GroupedQuestionItem('At School / Work', 'Someone listens when I need to talk'),
    GroupedQuestionItem('At School / Work', 'Someone believes I will succeed'),
    GroupedQuestionItem('At Home', 'Someone supports and listens to me'),
    GroupedQuestionItem('At Home', 'Someone encourages me to do my best'),
    GroupedQuestionItem('Friends & Social', 'I have friends who include me in activities'),
    GroupedQuestionItem('Friends & Social', 'I have people who help me when I need it'),
    GroupedQuestionItem('Friends & Social', 'I feel accepted by others'),
  ];

  static const List<QuestionItem> _strengths = <QuestionItem>[
    QuestionItem('I can solve problems when they arise'),
    QuestionItem('I can do things well if I try'),
    QuestionItem('I have skills or strengths I am proud of'),
    QuestionItem('I try to understand other people feelings'),
    QuestionItem('I know where to go for help'),
    QuestionItem('I have goals for my future'),
  ];

  static const List<QuestionItem> _life = <QuestionItem>[
    QuestionItem('My life is going well'),
    QuestionItem('I feel satisfied with my life'),
    QuestionItem('I wish I could change many things in my life', reverseScored: true),
    QuestionItem('I feel I have a good life'),
    QuestionItem('I believe I will have a successful future'),
  ];

  int get _emotionScore => _sumAnswers(_emotionAnswers);
  int get _behaviorScore => _sumAnswers(_behaviorAnswers);
  int get _supportScore => _sumAnswers(_supportAnswers);
  int get _strengthScore => _sumAnswers(_strengthAnswers);
  int get _lifeScore => _sumAnswers(_lifeAnswers, reverseIndexes: <int>{2});
  int get _concernScore => _emotionScore + _behaviorScore;
  int get _protectiveScore => _supportScore + _strengthScore + _lifeScore;

  int get _finalAdjustment {
    switch (_finalAnswer) {
      case 1:
        return 2;
      case 2:
        return -2;
      default:
        return 0;
    }
  }

  int get _overallScore => _protectiveScore - _concernScore + _finalAdjustment;

  WellbeingStatus get _status {
    if (_overallScore >= 18) {
      return WellbeingStatus.good;
    }
    if (_overallScore >= 6) {
      return WellbeingStatus.moderate;
    }
    return WellbeingStatus.low;
  }

  bool get _isComplete {
    return _emotionAnswers.every((e) => e != null) &&
        _behaviorAnswers.every((e) => e != null) &&
        _supportAnswers.every((e) => e != null) &&
        _strengthAnswers.every((e) => e != null) &&
        _lifeAnswers.every((e) => e != null) &&
        _finalAnswer != null;
  }

  List<String> get _focusAreas {
    final areas = <MapEntry<String, int>>[
      MapEntry('Emotions', _emotionScore),
      MapEntry('Behaviour', _behaviorScore),
      MapEntry('Support System', _supportScore),
      MapEntry('Personal Strengths', _strengthScore),
      MapEntry('Life Satisfaction', _lifeScore),
    ]..sort((a, b) => a.value.compareTo(b.value));

    return areas.take(3).map((e) => e.key).toList();
  }

  List<String> get _suggestions {
    final items = <String>[];
    if (_emotionScore >= 6 || _behaviorScore >= 6) {
      items.add('Consider rest, emotional check-ins, and speaking with someone you trust.');
    }
    if (_supportScore <= 8) {
      items.add('Look for one person you can reach out to for support this week.');
    }
    if (_strengthScore <= 6) {
      items.add('Write down one strength or success you noticed recently.');
    }
    if (_lifeScore <= 8) {
      items.add('Focus on one small life area you want to improve first.');
    }
    if (items.isEmpty) {
      items.add('Keep using the routines and support that are working for you.');
    }
    return items;
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
      await _service.addWellbeingAssessment(
        uid: user.uid,
        emotionsAnswers: _emotionAnswers,
        behaviorAnswers: _behaviorAnswers,
        supportAnswers: _supportAnswers,
        strengthAnswers: _strengthAnswers,
        lifeAnswers: _lifeAnswers,
        finalAnswer: _finalAnswer ?? 0,
        emotionScore: _emotionScore,
        behaviorScore: _behaviorScore,
        supportScore: _supportScore,
        strengthScore: _strengthScore,
        lifeScore: _lifeScore,
        concernScore: _concernScore,
        protectiveScore: _protectiveScore,
        finalAdjustment: _finalAdjustment,
        overallScore: _overallScore,
        riskStatus: _status.label,
        resultMessage: _status.message,
        focusAreas: _focusAreas,
        suggestions: _suggestions,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wellbeing check submitted successfully.')),
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
        const SnackBar(content: Text('Failed to submit wellbeing check.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  int _sumAnswers(List<int?> answers, {Set<int> reverseIndexes = const <int>{}}) {
    var total = 0;
    for (var i = 0; i < answers.length; i++) {
      final v = answers[i] ?? 0;
      total += reverseIndexes.contains(i) ? 4 - v : v;
    }
    return total;
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _buildSectionEmotions(),
      _buildSectionBehaviour(),
      _buildSectionSupport(),
      _buildSectionStrengths(),
      _buildSectionLifeSatisfaction(),
      _buildFinalSection(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Wellbeing Check')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: LinearProgressIndicator(value: (_pageIndex + 1) / pages.length),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
              children: pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pageIndex == 0 ? null : () => _goTo(_pageIndex - 1),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pageIndex == pages.length - 1 ? null : () => _goTo(_pageIndex + 1),
                    child: Text(_pageIndex == pages.length - 1 ? 'Last Section' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionEmotions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Section 1: Emotions',
            instruction: 'In the past few weeks, how often have you felt this way?',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _emotions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceQuestionCard(
                number: i + 1,
                text: _emotions[i].text,
                value: _emotionAnswers[i],
                options: _threePointScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
                onChanged: (value) => setState(() => _emotionAnswers[i] = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionBehaviour() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Section 2: Behaviour & Reactions', instruction: 'How often do these happen?'),
          const SizedBox(height: 12),
          for (int i = 0; i < _behaviour.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceQuestionCard(
                number: i + 1,
                text: _behaviour[i].text,
                value: _behaviorAnswers[i],
                options: _threePointScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
                onChanged: (value) => setState(() => _behaviorAnswers[i] = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionSupport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Section 3: Support System', instruction: 'Think about the people around you.'),
          const SizedBox(height: 12),
          for (final group in <String>['At School / Work', 'At Home', 'Friends & Social']) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(group, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            for (var i = 0; i < _support.length; i++)
              if (_support[i].group == group)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ChoiceQuestionCard(
                    number: i + 1,
                    text: _support[i].text,
                    value: _supportAnswers[i],
                    options: _threePointScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
                    onChanged: (value) => setState(() => _supportAnswers[i] = value),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionStrengths() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Section 4: Personal Strengths', instruction: 'How true are these statements for you?'),
          const SizedBox(height: 12),
          for (int i = 0; i < _strengths.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceQuestionCard(
                number: i + 1,
                text: _strengths[i].text,
                value: _strengthAnswers[i],
                options: _threePointScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
                onChanged: (value) => setState(() => _strengthAnswers[i] = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLifeSatisfaction() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Section 5: Life Satisfaction',
            instruction: 'Please choose the option that best matches how you feel.',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _life.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ChoiceQuestionCard(
                number: i + 1,
                text: _life[i].text,
                value: _lifeAnswers[i],
                options: _fivePointScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
                onChanged: (value) => setState(() => _lifeAnswers[i] = value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinalSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Final Question',
            instruction: 'After completing this check, how do you feel?',
          ),
          const SizedBox(height: 12),
          ChoiceQuestionCard(
            number: null,
            text: 'How do you feel after completing this check?',
            value: _finalAnswer,
            options: _finalScale.map((o) => ChoiceOption(label: o.label, value: o.value)).toList(),
            onChanged: (value) => setState(() => _finalAnswer = value),
          ),
          const SizedBox(height: 14),
          WellbeingResultCard(
            status: _status,
            overallScore: _overallScore,
            concernScore: _concernScore,
            protectiveScore: _protectiveScore,
            emotionScore: _emotionScore,
            behaviorScore: _behaviorScore,
            supportScore: _supportScore,
            strengthScore: _strengthScore,
            lifeScore: _lifeScore,
            finalAdjustment: _finalAdjustment,
            suggestions: _suggestions,
            focusAreas: _focusAreas,
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
    );
  }
}

class WellbeingResultCard extends StatelessWidget {
  const WellbeingResultCard({
    super.key,
    required this.status,
    required this.overallScore,
    required this.concernScore,
    required this.protectiveScore,
    required this.emotionScore,
    required this.behaviorScore,
    required this.supportScore,
    required this.strengthScore,
    required this.lifeScore,
    required this.finalAdjustment,
    required this.suggestions,
    required this.focusAreas,
  });

  final WellbeingStatus status;
  final int overallScore;
  final int concernScore;
  final int protectiveScore;
  final int emotionScore;
  final int behaviorScore;
  final int supportScore;
  final int strengthScore;
  final int lifeScore;
  final int finalAdjustment;
  final List<String> suggestions;
  final List<String> focusAreas;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wellbeing Result', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TriggerRow(label: 'Overall score', value: '$overallScore'),
            const SizedBox(height: 6),
            TriggerRow(label: 'Concern score', value: '$concernScore'),
            const SizedBox(height: 6),
            TriggerRow(label: 'Protective score', value: '$protectiveScore'),
            const SizedBox(height: 12),
            StatusPanel(
              label: status.label,
              message: status.message,
              color: status.color,
              emoji: status == WellbeingStatus.good ? '🟢' : status == WellbeingStatus.moderate ? '🟡' : '🔴',
            ),
            const SizedBox(height: 12),
            TriggerRow(label: 'Emotions', value: '$emotionScore'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Behaviour', value: '$behaviorScore'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Support', value: '$supportScore'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Strengths', value: '$strengthScore'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Life satisfaction', value: '$lifeScore'),
            const SizedBox(height: 5),
            TriggerRow(label: 'Final adjustment', value: '$finalAdjustment'),
            const SizedBox(height: 10),
            const Text('Focus areas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            Text(focusAreas.isEmpty ? 'None' : focusAreas.join(', '), style: const TextStyle(fontSize: 12.5, height: 1.35)),
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
