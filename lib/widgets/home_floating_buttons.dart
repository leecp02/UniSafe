import 'package:flutter/material.dart';

import '../screens/chatbot_page.dart';
import '../screens/create_event_post_page.dart';
import '../screens/create_forum_post_page.dart';

class HomeFloatingButtons extends StatelessWidget {
  final TabController controller;
  final bool isCounsellor;

  const HomeFloatingButtons({
    super.key,
    required this.controller,
    required this.isCounsellor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bool isForumTab = controller.index == 0;
        final bool isEventTab = controller.index == 1;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isForumTab) ...[
              FloatingActionButton(
                heroTag: "create_post",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateForumPostPage(),
                    ),
                  );
                },
                child: const Icon(Icons.edit),
              ),
              const SizedBox(height: 12),
            ],

            if (isCounsellor && isEventTab) ...[
              FloatingActionButton(
                heroTag: 'create_event',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateEventPostPage(),
                    ),
                  );
                },
                child: const Icon(Icons.event_available_outlined),
              ),
              const SizedBox(height: 12),
            ],

            // CHATBOT BUTTON
            FloatingActionButton(
              heroTag: "chatbot",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatbotPage(isCounsellor: isCounsellor),
                  ),
                );
              },
              child: const Icon(Icons.smart_toy),
            ),
          ],
        );
      },
    );
  }
}