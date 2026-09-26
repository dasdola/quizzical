/// Snapshot of a finished quiz session, handed to the results screen.
class QuizResult {
  const QuizResult({
    required this.score,
    required this.total,
    required this.elapsed,
  });

  final int score;
  final int total;
  final Duration elapsed;

  int get accuracyPercent =>
      total == 0 ? 0 : ((score / total) * 100).round();

  /// mm:ss
  String get formattedTime {
    final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
