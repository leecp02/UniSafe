import 'package:flutter/material.dart';

import 'mdq_assessment_page.dart';
import 'stress_assessment_page.dart';
import 'wellbeing_assessment_page.dart';

class CheckCategoriesPage extends StatelessWidget {
  const CheckCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Check')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CategoryTile(
            icon: Icons.psychology_outlined,
            title: 'Stress Check',
            subtitle: 'Measure pressure, load, and tension levels.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StressAssessmentPage()),
            ),
          ),
          const SizedBox(height: 12),
          _CategoryTile(
            icon: Icons.self_improvement_outlined,
            title: 'Mood Check',
            subtitle: 'Quickly capture how you feel today.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MdqAssessmentPage(categoryLabel: 'Mood Check')),
            ),
          ),
          const SizedBox(height: 12),
          _CategoryTile(
            icon: Icons.favorite_outline,
            title: 'Wellbeing Check',
            subtitle: 'General mental wellbeing and support guidance.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WellbeingAssessmentPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap == null ? null : const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
