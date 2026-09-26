import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/quiz_options.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/adaptive_scroll.dart';
import '../widgets/error_banner.dart';
import '../widgets/illustration_badge.dart';
import '../widgets/labeled_dropdown.dart';
import 'quiz_screen.dart';

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key, required this.category});

  /// The category picked on the previous screen.
  final Category category;

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  /// Used by both START and RETRY. The configuration lives in the provider,
  /// so a retry uses exactly the same settings.
  Future<void> _startQuiz() async {
    final started = await context.read<QuizProvider>().startQuiz();
    if (!mounted || !started) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const QuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = context.watch<QuizProvider>();
    final loading = quiz.questionsLoading;
    final error = quiz.questionsError;
    final illustrationSize =
        (MediaQuery.sizeOf(context).shortestSide * 0.32).clamp(100.0, 160.0).toDouble();

    return Scaffold(
      body: SafeArea(
        child: AdaptiveScroll(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: IllustrationBadge(
                  icon: Icons.tune_rounded,
                  size: illustrationSize,
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                header: true,
                child: Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Configuration',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.category.displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Number of Questions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select ${QuizConstants.minQuestions}-${QuizConstants.maxQuestions}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    '${quiz.amount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: quiz.amount.toDouble(),
                min: QuizConstants.minQuestions.toDouble(),
                max: QuizConstants.maxQuestions.toDouble(),
                divisions: QuizConstants.maxQuestions - QuizConstants.minQuestions,
                label: '${quiz.amount}',
                semanticFormatterCallback: (value) =>
                    '${value.round()} questions',
                onChanged:
                    loading ? null : (value) => quiz.setAmount(value.round()),
              ),
              const SizedBox(height: 12),
              LabeledDropdown<QuizDifficulty>(
                label: 'Difficulty Level',
                value: quiz.difficulty,
                options: QuizDifficulty.values,
                labelOf: (option) => option.label,
                onChanged: loading ? null : quiz.setDifficulty,
              ),
              const SizedBox(height: 16),
              LabeledDropdown<QuizType>(
                label: 'Question Type',
                value: quiz.type,
                options: QuizType.values,
                labelOf: (option) => option.label,
                onChanged: loading ? null : quiz.setType,
              ),
              const SizedBox(height: 24),
              if (error != null) ...[
                ErrorBanner(message: error, onRetry: _startQuiz),
                const SizedBox(height: 16),
              ],
              OutlinedButton(
                onPressed: loading ? null : _startQuiz,
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          semanticsLabel: 'Loading questions',
                        ),
                      )
                    : const Text('START'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
