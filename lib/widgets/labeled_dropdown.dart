import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Label + outlined dropdown, used on the configuration screen.
class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> options;
  final String Function(T option) labelOf;

  /// Null disables the dropdown.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final handler = onChanged;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final option in options)
                    DropdownMenuItem<T>(
                      value: option,
                      child: Text(labelOf(option)),
                    ),
                ],
                onChanged: handler == null
                    ? null
                    : (T? selected) {
                        if (selected != null) handler(selected);
                      },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
