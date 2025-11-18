import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:famai/models/weather_model.dart';
import 'package:famai/utils/secrets.dart';

class WeatherService {
  final String _apiKey = openWeatherMapApiKey;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeather(double lat, double lon) async {
    final url = '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
