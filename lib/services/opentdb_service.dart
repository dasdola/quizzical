import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/question.dart';
import '../models/quiz_options.dart';

/// An error with a message that is safe to show to the user.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenTdbService {
  OpenTdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _host = 'opentdb.com';
  static const Duration _timeout = Duration(seconds: 15);

  Future<List<Category>> fetchCategories() async {
    final json = await _getJson(Uri.https(_host, '/api_category.php'));
    final raw = json['trivia_categories'];
    if (raw is! List) {
      throw ApiException('Received an unexpected response. Please try again.');
    }
    return raw
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Question>> fetchQuestions({
    required int amount,
    required int categoryId,
    required QuizDifficulty difficulty,
    required QuizType type,
  }) async {
    final params = <String, String>{
      'amount': '$amount',
      'category': '$categoryId',
      // "Any" difficulty: omit the parameter entirely.
      if (difficulty.apiValue != null) 'difficulty': difficulty.apiValue!,
      'type': type.apiValue,
    };

    final json = await _getJson(Uri.https(_host, '/api.php', params));

    final code = json['response_code'];
    if (code is! int) {
      throw ApiException('Received an unexpected response. Please try again.');
    }
    if (code != 0) {
      throw ApiException(_messageForResponseCode(code));
    }

    final raw = json['results'];
    if (raw is! List || raw.isEmpty) {
      throw ApiException(_messageForResponseCode(1));
    }
    return raw
        .map((item) => Question.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 429) {
        throw ApiException(_messageForResponseCode(5));
      }
      if (response.statusCode != 200) {
        throw ApiException(
          'The server had a problem (${response.statusCode}). Please try again.',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
            'Received an unexpected response. Please try again.');
      }
      return decoded;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Received an unexpected response. Please try again.');
    } catch (_) {
      throw ApiException(
        'Could not connect. Check your internet connection and try again.',
      );
    }
  }

  /// OpenTDB response codes (0 is success and never reaches this method).
  String _messageForResponseCode(int code) {
    switch (code) {
      case 1:
        return 'Not enough questions are available for these settings. '
            'Try fewer questions, or change the difficulty or type.';
      case 2:
        return 'These quiz settings were not accepted. '
            'Please change them and try again.';
      case 3:
      case 4:
        return 'The question session has expired. Please try again.';
      case 5:
        return 'Too many requests. Please wait a few seconds and press Retry.';
      default:
        return 'Something went wrong (code $code). Please try again.';
    }
  }

  void dispose() => _client.close();
}
