import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'info_chip.dart';

/// Countdown display. Rebuilds itself every second without rebuilding the
/// rest of the quiz screen.
class QuizTimerChip extends StatelessWidget {
  const QuizTimerChip({super.key, required this.remaining});

  final ValueListenable<int> remaining;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: remaining,
      builder: (context, seconds, _) {
        final urgent = seconds <= 5;
        return InfoChip(
          icon: Icons.timer_outlined,
          text: '${seconds}s',
          semanticLabel: 'Time remaining: $seconds seconds',
          color: urgent ? AppColors.error : AppColors.primary,
        );
      },
    );
  }
}
