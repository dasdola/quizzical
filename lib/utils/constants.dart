/// Text used in more than one place.
class AppStrings {
  AppStrings._();

  static const String appName = 'Quizzical';

  /// The Figma welcome screen shows "Your_Name" under the app title.
  /// Replace this with your own name if you want.
  static const String studentName = 'Your_Name';

  static const String startQuiz = 'START QUIZ';
}

class AppRoutes {
  AppRoutes._();

  /// Used to pop back to the category screen (Play Again / Exit).
  static const String categories = '/categories';
}

class QuizConstants {
  QuizConstants._();

  static const int minQuestions = 1;
  static const int maxQuestions = 50;
  static const int defaultQuestions = 10;

  /// Time allowed per question (assignment suggests 20-30 seconds).
  static const int questionSeconds = 20;

  /// After a timeout, the correct answer is shown briefly before the quiz
  /// automatically moves to the next question.
  static const Duration timeoutRevealDelay = Duration(milliseconds: 1500);

  /// Accuracy (%) at or above which the "Congratulation" result is shown,
  /// otherwise the "Keep Trying!" result from the design is shown.
  static const int passPercent = 50;
}
