import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/answer_button.dart';
import '../widgets/info_chip.dart';
import '../widgets/quiz_timer_chip.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizProvider _quiz;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _quiz = context.read<QuizProvider>();
    _quiz.addListener(_onQuizChanged);
    // Start the first question's timer only once this screen is on screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _quiz.beginQuiz();
    });
  }

  /// Handles the end of the quiz, whether it ended through the Next button
  /// or through an automatic advance after a timeout.
  void _onQuizChanged() {
    if (!mounted || _navigatedToResult || !_quiz.isFinished) return;
    final result = _quiz.result;
    if (result == null) return;
    _navigatedToResult = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
    );
  }

  void _exit() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.categories || route.isFirst,
    );
  }

  @override
  void dispose() {
    _quiz.removeListener(_onQuizChanged);
    // Guarantees no timer keeps running after leaving the quiz.
    _quiz.cancelTimers();
    super.dispose();
  }

  AnswerState _stateFor(String answer, Question question, QuizProvider quiz) {
    if (!quiz.isAnswered) return AnswerState.idle;
    if (question.isCorrect(answer)) return AnswerState.correct;
    if (answer == quiz.selectedAnswer) return AnswerState.incorrect;
    return AnswerState.locked;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.currentQuestion;

    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final total = quiz.totalQuestions;
    final number = quiz.currentIndex + 1;
    final answeredCorrectly = quiz.selectedAnswer != null &&
        question.isCorrect(quiz.selectedAnswer!);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Question $number / $total'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _exit,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('EXIT'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink,
                minimumSize: const Size(48, 48),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: number / total,
            minHeight: 6,
            backgroundColor: const Color(0xFFDDE4E3),
            color: AppColors.primary,
            semanticsLabel: 'Quiz progress',
            semanticsValue: 'Question $number of $total',
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoChip(
                        icon: Icons.star_rounded,
                        text: 'Score: ${quiz.score}',
                        semanticLabel: 'Score: ${quiz.score}',
                      ),
                      QuizTimerChip(remaining: quiz.remainingSeconds),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _QuestionCard(text: question.text),
                          const SizedBox(height: 16),
                          for (final answer in question.answers)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnswerButton(
                                label: answer,
                                state: _stateFor(answer, question, quiz),
                                onTap: quiz.isAnswered
                                    ? null
                                    : () => quiz.submitAnswer(answer),
                              ),
                            ),
                          if (quiz.isAnswered)
                            _FeedbackMessage(
                              timedOut: quiz.timedOut,
                              isCorrect: answeredCorrectly,
                              correctAnswer: question.correctAnswer,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: quiz.isAnswered && !quiz.timedOut
                        ? quiz.nextQuestion
                        : null,
                    child: Text(quiz.isLastQuestion ? 'FINISH' : 'NEXT'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

/// Text feedback so correct/incorrect never relies on colour alone.
class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({
    required this.timedOut,
    required this.isCorrect,
    required this.correctAnswer,
  });

  final bool timedOut;
  final bool isCorrect;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final String message;
    final IconData icon;
    final Color accent;

    if (timedOut) {
      message = "Time's up! The correct answer is: $correctAnswer";
      icon = Icons.timer_off_rounded;
      accent = AppColors.incorrectDark;
    } else if (isCorrect) {
      message = 'Correct!';
      icon = Icons.check_circle_rounded;
      accent = AppColors.correctDark;
    } else {
      message = 'Incorrect. The correct answer is: $correctAnswer';
      icon = Icons.cancel_rounded;
      accent = AppColors.incorrectDark;
    }

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
