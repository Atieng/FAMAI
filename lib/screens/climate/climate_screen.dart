import 'package:flutter/material.dart';
import 'package:famai/models/weather_model.dart';
import 'package:famai/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  final _weatherService = WeatherService();
  Future<Weather>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    try {
      // First check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _weatherFuture = Future.error('Location services are disabled. Please enable location in your device settings.');
        });
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _weatherFuture = Future.error('Location permission was denied. Please allow location access to see weather data.');
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _weatherFuture = Future.error(
            'Location permission is permanently denied. Please enable location access in app settings.'
          );
        });
        return;
      }

      // We have permission, so get the location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Use a fixed location if in debug mode or emulator
      if (position.latitude == 0 && position.longitude == 0) {
        // Using Yogyakarta as default location
        position = Position(
          latitude: -7.7956, 
          longitude: 110.3695,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0
        );
      }
      
      // Fetch weather data
      setState(() {
        _weatherFuture = _weatherService.getWeather(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _weatherFuture = Future.error('Error accessing location: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: RefreshIndicator(
        onRefresh: _fetchWeatherForCurrentLocation,
        child: FutureBuilder<Weather>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading weather data...'),
                  ],
                ),
              );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchWeatherForCurrentLocation,
                      icon: Icon(Icons.refresh),
                      label: Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No weather data available.'),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchWeatherForCurrentLocation,
                      icon: Icon(Icons.refresh),
                      label: Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

          final weather = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weather',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.toStringAsFixed(1)}°C',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(
                          weather.description,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWeatherDetailRow('Feels Like', '${weather.feelsLike.toStringAsFixed(1)}°C'),
                _buildWeatherDetailRow('Humidity', '${weather.humidity}%'),
                _buildWeatherDetailRow('Wind Speed', '${weather.windSpeed} m/s'),
                _buildWeatherDetailRow('Cloudiness', '${weather.clouds}%'),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildWeatherDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
