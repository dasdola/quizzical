import 'dart:async';

import 'package:flutter/foundation.dart'
    show ChangeNotifier, ValueListenable, ValueNotifier, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_options.dart';
import '../models/quiz_result.dart';
import '../services/opentdb_service.dart';
import '../utils/constants.dart';

/// Holds all application state: categories, quiz configuration, questions
/// and the running quiz session (score, current question, timer).
class QuizProvider extends ChangeNotifier {
  QuizProvider({
    required OpenTdbService service,
    required SharedPreferences prefs,
  })  : _service = service,
        _prefs = prefs {
    _restoreConfiguration();
  }

  final OpenTdbService _service;
  final SharedPreferences _prefs;

  static const String _amountKey = 'quiz_amount';
  static const String _difficultyKey = 'quiz_difficulty';
  static const String _typeKey = 'quiz_type';
  static const String _genericError =
      'Something went wrong. Please try again.';

  // ---------------------------------------------------------------- categories
  List<Category> _categories = const [];
  bool _categoriesLoading = false;
  String? _categoriesError;
  Category? _selectedCategory;

  List<Category> get categories => _categories;
  bool get categoriesLoading => _categoriesLoading;
  String? get categoriesError => _categoriesError;
  Category? get selectedCategory => _selectedCategory;

  /// Fetches categories once per session. Later calls return immediately
  /// unless [force] is true (used by the Retry button).
  Future<void> loadCategories({bool force = false}) async {
    if (_categoriesLoading) return;
    if (_categories.isNotEmpty && !force) return;

    _categoriesLoading = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
      if (_categories.isEmpty) {
        _categoriesError = 'No categories were found. Please try again.';
      }
    } on ApiException catch (e) {
      _categoriesError = e.message;
    } catch (_) {
      _categoriesError = _genericError;
    }

    _categoriesLoading = false;
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    _questionsError = null;
    notifyListeners();
  }

  // ------------------------------------------------------------- configuration
  int _amount = QuizConstants.defaultQuestions;
  QuizDifficulty _difficulty = QuizDifficulty.any;
  QuizType _type = QuizType.multiple;

  int get amount => _amount;
  QuizDifficulty get difficulty => _difficulty;
  QuizType get type => _type;

  void setAmount(int value) {
    final next = value
        .clamp(QuizConstants.minQuestions, QuizConstants.maxQuestions)
        .toInt();
    if (next == _amount) return;
    _amount = next;
    notifyListeners();
  }

  void setDifficulty(QuizDifficulty value) {
    if (value == _difficulty) return;
    _difficulty = value;
    notifyListeners();
  }

  void setType(QuizType value) {
    if (value == _type) return;
    _type = value;
    notifyListeners();
  }

  /// Reads the last used configuration from SharedPreferences.
  void _restoreConfiguration() {
    final savedAmount = _prefs.getInt(_amountKey);
    _amount = savedAmount == null
        ? QuizConstants.defaultQuestions
        : savedAmount
            .clamp(QuizConstants.minQuestions, QuizConstants.maxQuestions)
            .toInt();
    _difficulty = QuizDifficulty.values
            .asNameMap()[_prefs.getString(_difficultyKey)] ??
        QuizDifficulty.any;
    _type =
        QuizType.values.asNameMap()[_prefs.getString(_typeKey)] ?? QuizType.multiple;
  }

  Future<void> _saveConfiguration() async {
    try {
      await Future.wait([
        _prefs.setInt(_amountKey, _amount),
        _prefs.setString(_difficultyKey, _difficulty.name),
        _prefs.setString(_typeKey, _type.name),
      ]);
    } catch (e) {
      debugPrint('Could not save quiz configuration: $e');
    }
  }

  // ---------------------------------------------------------------- questions
  List<Question> _questions = const [];
  bool _questionsLoading = false;
  String? _questionsError;

  bool get questionsLoading => _questionsLoading;
  String? get questionsError => _questionsError;
  int get totalQuestions => _questions.length;

  /// Fetches questions using the current configuration and the selected
  /// category. Returns true when the quiz is ready to be shown. Calling it
  /// again after a failure (Retry) reuses the same configuration.
  Future<bool> startQuiz() async {
    final category = _selectedCategory;
    if (category == null || _questionsLoading) return false;

    cancelTimers();
    _questionsLoading = true;
    _questionsError = null;
    notifyListeners();

    unawaited(_saveConfiguration());

    try {
      final questions = await _service.fetchQuestions(
        amount: _amount,
        categoryId: category.id,
        difficulty: _difficulty,
        type: _type,
      );
      _resetSession();
      _questions = questions;
      _questionsLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _questionsError = e.message;
    } catch (_) {
      _questionsError = _genericError;
    }

    _questionsLoading = false;
    notifyListeners();
    return false;
  }

  // ------------------------------------------------------------------ session
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _timedOut = false;
  bool _isFinished = false;
  QuizResult? _result;

  final Stopwatch _stopwatch = Stopwatch();
  final ValueNotifier<int> _remaining =
      ValueNotifier<int>(QuizConstants.questionSeconds);
  Timer? _ticker;
  Timer? _advanceTimer;

  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get isAnswered => _isAnswered;
  bool get timedOut => _timedOut;
  bool get isFinished => _isFinished;
  QuizResult? get result => _result;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;

  /// Countdown for the current question. Listened to by the timer chip only,
  /// so the rest of the quiz screen does not rebuild every second.
  ValueListenable<int> get remainingSeconds => _remaining;

  Question? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;

  /// Called by the quiz screen once it is on screen.
  void beginQuiz() {
    if (_questions.isEmpty || _isFinished) return;
    _stopwatch
      ..reset()
      ..start();
    _startTicker();
  }

  void submitAnswer(String answer) {
    final question = currentQuestion;
    if (question == null || _isAnswered || _isFinished) return;

    cancelTimers();
    _selectedAnswer = answer;
    _isAnswered = true;
    _timedOut = false;
    if (question.isCorrect(answer)) _score++;
    notifyListeners();
  }

  void nextQuestion() {
    if (!_isAnswered || _isFinished) return;

    cancelTimers();
    if (isLastQuestion) {
      _finishQuiz();
      return;
    }

    _currentIndex++;
    _selectedAnswer = null;
    _isAnswered = false;
    _timedOut = false;
    notifyListeners();
    _startTicker();
  }

  /// Clears the finished session (Play Again). The saved configuration is
  /// read back from SharedPreferences so it stays available.
  void resetQuiz() {
    cancelTimers();
    _resetSession();
    _questions = const [];
    _questionsError = null;
    _restoreConfiguration();
    notifyListeners();
  }

  /// Stops every running timer. Does not notify listeners, so it is safe to
  /// call from a widget's dispose().
  void cancelTimers() {
    _ticker?.cancel();
    _ticker = null;
    _advanceTimer?.cancel();
    _advanceTimer = null;
  }

  void _startTicker() {
    cancelTimers();
    _remaining.value = QuizConstants.questionSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _remaining.value - 1;
      _remaining.value = next;
      if (next <= 0) {
        timer.cancel();
        _ticker = null;
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_isAnswered || _isFinished) return;

    _isAnswered = true;
    _timedOut = true;
    _selectedAnswer = null;
    notifyListeners();

    // Show the correct answer briefly, then advance automatically.
    _advanceTimer = Timer(QuizConstants.timeoutRevealDelay, nextQuestion);
  }

  void _finishQuiz() {
    _stopwatch.stop();
    _result = QuizResult(
      score: _score,
      total: _questions.length,
      elapsed: _stopwatch.elapsed,
    );
    _isFinished = true;
    notifyListeners();
  }

  void _resetSession() {
    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isAnswered = false;
    _timedOut = false;
    _isFinished = false;
    _result = null;
    _stopwatch
      ..stop()
      ..reset();
    _remaining.value = QuizConstants.questionSeconds;
  }

  @override
  void dispose() {
    cancelTimers();
    _remaining.dispose();
    _service.dispose();
    super.dispose();
  }
}
