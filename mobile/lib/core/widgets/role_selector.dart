import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Your role', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'mom', label: Text('Mom')),
            ButtonSegment(value: 'dad', label: Text('Dad')),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.single),
          showSelectedIcon: false,
        ),
      ),
    ],
  );
}
