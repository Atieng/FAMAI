import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plant_disease_model.dart';
import '../utils/disease_analysis.dart';

class PlantDiseaseService {
  static const String baseUrl = 'http://192.168.0.113:5000';
  static const String detectEndpoint = '$baseUrl/detect';
  
  static Future<PlantDiseaseResponse> detectDisease(File imageFile, {String language = 'en'}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(detectEndpoint));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      request.fields['lang'] = language;
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlantDiseaseResponse.fromJson(data);
      } else {
        return PlantDiseaseResponse(
          results: [],
          error: 'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      return PlantDiseaseResponse(
        results: [],
        error: 'Error connecting to API: $e',
      );
    }
  }
  
  // Analyze disease results and provide recommendations
  static DiseaseAnalysis analyzeResult(PlantDiseaseResult result) {
    return DiseaseAnalysis.fromDiseaseResult(result);
  }
  
  // Health check for the backend
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
