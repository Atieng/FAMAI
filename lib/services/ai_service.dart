import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:famai/utils/secrets.dart';

class AIService {
  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(model: 'gemini-pro', apiKey: geminiApiKey);

  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Sorry, I could not process that.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
