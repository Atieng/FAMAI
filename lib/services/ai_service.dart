import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'sk-3d0d0177448043fd9835122d634cc5d3';
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful agricultural assistant. Provide accurate, practical advice about farming, plant diseases, crop management, and sustainable agriculture. Be concise but thorough.'
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'Sorry, I could not process that.';
      } else {
        return 'Error: API request failed with status ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> getAgriculturalAdvice(String topic) async {
    final prompt = 'As an agricultural expert, provide detailed advice about: $topic. Include practical steps, best practices, and considerations for farmers.';
    return sendMessage(prompt);
  }

  Future<String> analyzePlantProblem(String description) async {
    final prompt = 'Analyze this plant problem and provide solutions: $description. Include possible causes, symptoms to look for, and recommended treatments.';
    return sendMessage(prompt);
  }
}
