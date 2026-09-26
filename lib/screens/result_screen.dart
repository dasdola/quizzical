import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/quiz_result.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/adaptive_scroll.dart';
import '../widgets/illustration_badge.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  /// Snapshot of the session that just finished.
  final QuizResult result;

  void _playAgain(BuildContext context) {
    context.read<QuizProvider>().resetQuiz();
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.categories || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = result.accuracyPercent;
    final passed = percent >= QuizConstants.passPercent;

    final badgeColor = passed ? AppColors.correct : AppColors.warmBadge;
    final badgeTextColor = passed ? AppColors.ink : Colors.white;
    final title = passed ? 'Congratulation' : 'Keep Trying!';
    final message = passed
        ? "You've got a great foundation. Ready to try a different category?"
        : "Don't give up! Practice makes perfect. Try again to improve your score.";
    final illustrationSize =
        (MediaQuery.sizeOf(context).shortestSide * 0.45).clamp(120.0, 220.0).toDouble();

    return Scaffold(
      body: SafeArea(
        child: AdaptiveScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: IllustrationBadge(
                      icon: passed
                          ? Icons.celebration_rounded
                          : Icons.tips_and_updates_rounded,
                      size: illustrationSize,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You scored ${result.score}/${result.total}!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Semantics(
                      label: 'Accuracy $percent percent',
                      excludeSemantics: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$percent%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: badgeTextColor,
                              ),
                            ),
                            Text(
                              'Accuracy',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: badgeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Total time: ${result.formattedTime}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: ElevatedButton(
                  onPressed: () => _playAgain(context),
                  child: const Text('PLAY AGAIN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
