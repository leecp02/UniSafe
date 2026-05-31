import 'package:flutter/material.dart';

import 'self_check/check_categories_page.dart';
import '../widgets/self_check_landing_widgets.dart';

class SelfCheckPage extends StatelessWidget {
  const SelfCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CheckNowCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CheckCategoriesPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Useful information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const CheckTrendCarousel(),
          const SizedBox(height: 20),
          InsightCard(
            icon: Icons.history,
            title: 'History / Record',
            subtitle: 'Your previous check results and submission date-time.',
            child: CheckHistoryList(),
          ),
        ],
      ),
    );
  }
}
