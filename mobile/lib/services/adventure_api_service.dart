import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/adventure_models.dart';

class AdventureApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<AdventureChapter>> generateAdventure({
    required String field,
    required String topic,
    required String level,
    required String mode,
  }) async {
    final url = Uri.parse('$baseUrl/generate-adventure');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'field': field,
        'topic': topic,
        'level': level,
        'mode': mode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Backend hata verdi: ${response.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final chaptersJson = decoded['chapters'] as List;

    return chaptersJson.map((item) {
      final optionsRaw = item['options'];
      final finalQuizRaw = item['finalQuiz'];

      final finalQuiz = finalQuizRaw is List
          ? finalQuizRaw.map((quizItem) {
              final quizOptionsRaw = quizItem['options'];

              return QuizQuestion(
                question: quizItem['question'] ?? 'Soru',
                options: quizOptionsRaw is List
                    ? List<String>.from(quizOptionsRaw)
                    : const [
                        'A seçeneği',
                        'B seçeneği',
                        'C seçeneği',
                        'D seçeneği',
                      ],
                correctIndex: quizItem['correctIndex'] ?? 0,
              );
            }).toList()
          : <QuizQuestion>[];

      return AdventureChapter(
        id: item['id'] ?? 1,
        title: item['title'] ?? 'Görev',
        subtitle: item['subtitle'] ?? '',
        story: item['story'] ?? '',
        explanation: item['explanation'] ?? '',
        memoryTip: item['memoryTip'] ?? '',
        question: item['question'] ?? '',
        options: optionsRaw is List
            ? List<String>.from(optionsRaw)
            : const [
                'A seçeneği',
                'B seçeneği',
                'C seçeneği',
                'D seçeneği',
              ],
        correctIndex: item['correctIndex'] ?? 0,
        isBoss: item['isBoss'] ?? false,
        finalQuiz: finalQuiz,
      );
    }).toList();
  }
}