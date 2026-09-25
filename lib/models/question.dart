import 'package:html_unescape/html_unescape.dart';

import 'quiz_options.dart';

class Question {
  const Question({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.text,
    required this.correctAnswer,
    required this.answers,
  });

  final QuizType type;
  final String difficulty;
  final String category;
  final String text;
  final String correctAnswer;

  /// Answer options in display order. Shuffled once when the question is
  /// created so the order never changes when the screen rebuilds.
  final List<String> answers;

  static final HtmlUnescape _unescape = HtmlUnescape();

  factory Question.fromJson(Map<String, dynamic> json) {
    String decode(Object? value) => _unescape.convert((value ?? '').toString());

    final type =
        json['type'] == 'boolean' ? QuizType.boolean : QuizType.multiple;
    final correct = decode(json['correct_answer']);
    final incorrect = (json['incorrect_answers'] as List<dynamic>)
        .map<String>(decode)
        .toList();

    final List<String> answers;
    if (type == QuizType.boolean) {
      answers = const ['True', 'False'];
    } else {
      answers = [correct, ...incorrect]..shuffle();
    }

    return Question(
      type: type,
      difficulty: decode(json['difficulty']),
      category: decode(json['category']),
      text: decode(json['question']),
      correctAnswer: correct,
      answers: answers,
    );
  }

  bool isCorrect(String answer) => answer == correctAnswer;
}
