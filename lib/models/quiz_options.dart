/// Difficulty choices. [apiValue] is null for "Any" so the parameter is
/// simply left out of the request (OpenTDB rejects an invalid value).
enum QuizDifficulty {
  any('Any', null),
  easy('Easy', 'easy'),
  medium('Medium', 'medium'),
  hard('Hard', 'hard');

  const QuizDifficulty(this.label, this.apiValue);

  final String label;
  final String? apiValue;
}

/// Question type choices (`multiple` / `boolean` in the API).
enum QuizType {
  multiple('Multiple Choice', 'multiple'),
  boolean('True / False', 'boolean');

  const QuizType(this.label, this.apiValue);

  final String label;
  final String apiValue;
}
