import 'dart:math';
import 'package:famai/models/weather_model.dart';

class WeatherService {
  // Using mock data for development, no API key needed
  static final List<String> _weatherDescriptions = [
    'clear sky',
    'few clouds',
    'scattered clouds',
    'broken clouds',
    'overcast clouds',
    'light rain',
    'moderate rain',
    'heavy rain',
    'thunderstorm',
    'mist',
  ];
  
  static final List<String> _iconCodes = [
    '01d', '02d', '03d', '04d', '09d', '10d', '11d', '13d', '50d'
  ];

  // Default location data for cases when generating data fails
  final Weather _defaultWeather = Weather(
    description: 'clear sky',
    temperature: 25.0,
    feelsLike: 26.0,
    humidity: 60,
    windSpeed: 3.5,
    clouds: 10,
    iconCode: '01d',
  );

  Future<Weather> getWeather(double lat, double lon) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Validate inputs to avoid errors
      if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
        return _defaultWeather;
      }
      
      // Use location to seed the random generator for consistent results by location
      final int seed = (lat * 1000).toInt() + (lon * 1000).toInt();
      final random = Random(seed.abs());
      
      // Generate pseudo-random but reasonable weather data
      return Weather(
        description: _weatherDescriptions[random.nextInt(_weatherDescriptions.length)],
        temperature: 20.0 + random.nextDouble() * 15.0, // 20-35°C
        feelsLike: 18.0 + random.nextDouble() * 15.0,   // 18-33°C
        humidity: 40 + random.nextInt(50),              // 40-90%
        windSpeed: 1.0 + random.nextDouble() * 9.0,     // 1-10 m/s
        clouds: random.nextInt(100),                    // 0-100%
        iconCode: _iconCodes[random.nextInt(_iconCodes.length)],
      );
    } catch (e) {
      // Return default weather if anything goes wrong
      return _defaultWeather;
    }
  }
}
