import 'package:flutter/material.dart';

class HomeTabBar extends StatelessWidget {
  final TabController controller;

  const HomeTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {

    return TabBar(
      controller: controller,
      tabs: const [
        Tab(text: "Forum"),
        Tab(text: "Event"),
      ],
    );
  }
}