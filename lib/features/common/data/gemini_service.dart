import 'package:http/http.dart' as http;
import 'dart:convert';
import '../domain/insight_type.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _apiKey = 'AIzaSyAdDQdyz5Lx7ZikLCJ5Ro6TvlQ_DNCgZas';  // Updated API key

  static Future<String> generateInsight(String text, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': '$prompt\n\nText: $text'
            }]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to generate insight');
      }
    } catch (e) {
      throw Exception('Error connecting to Gemini API: $e');
    }
  }

  static String getPromptForInsightType(InsightType type) {
    switch (type) {
      case InsightType.summary:
        return 'Provide a concise summary of the following text in 2-3 sentences.';
      case InsightType.sentiment:
        return 'Analyze the sentiment of the following text. Include the overall tone and key emotional indicators.';
      case InsightType.keywords:
        return 'Extract 5-7 key terms or phrases from the following text.';
      case InsightType.bulletPoints:
        return 'Convert the main points of the following text into 3-5 bullet points.';
    }
  }
} 