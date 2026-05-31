import 'package:flutter/material.dart';
import '../models/self_check_models.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.instruction});

  final String title;
  final String instruction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          instruction,
          style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.35),
        ),
      ],
    );
  }
}

class YesNoTile extends StatelessWidget {
  const YesNoTile({
    super.key,
    required this.number,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final int? number;
  final String text;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onChanged != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number == null ? text : '${number!}. $text',
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: enabled ? Colors.black87 : Colors.black38,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ToggleOption(
                    label: 'Yes',
                    selected: value == true,
                    enabled: enabled,
                    onTap: () => onChanged?.call(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToggleOption(
                    label: 'No',
                    selected: value == false,
                    enabled: enabled,
                    onTap: () => onChanged?.call(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = selected ? primary.withOpacity(0.15) : Colors.grey.withOpacity(0.1);
    final borderColor = selected ? primary : Colors.black26;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? bgColor : Colors.grey.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? borderColor : Colors.black12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: enabled ? (selected ? primary : Colors.black87) : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }
}

class TriggerRow extends StatelessWidget {
  const TriggerRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, height: 1.35),
          ),
        ),
      ],
    );
  }
}

class ChoiceQuestionCard extends StatelessWidget {
  const ChoiceQuestionCard({
    super.key,
    required this.number,
    required this.text,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int? number;
  final String text;
  final int? value;
  final List<ChoiceOption> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number == null ? text : '${number!}. $text',
              style: const TextStyle(fontSize: 14, height: 1.35),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map(
                    (option) => ChoiceChip(
                      label: Text(option.label),
                      selected: value == option.value,
                      onSelected: (_) => onChanged(option.value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.label,
    required this.message,
    required this.color,
    required this.emoji,
  });

  final String label;
  final String message;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji ', style: const TextStyle(fontSize: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(fontSize: 12.5, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
