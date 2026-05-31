import 'package:flutter/material.dart';

class StepsBar extends StatelessWidget {
  const StepsBar({super.key, required this.index, required this.len});

  final int index;
  final int len;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(len, (i) => Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i <= index ? Colors.blue : Colors.grey,
        ),
      )),
    );
  }
}