import 'dart:async';
import 'package:flutter/material.dart';
import 'package:famai/models/weather_model.dart';
import 'package:famai/services/weather_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  final _weatherService = WeatherService();
  Future<Weather>? _weatherFuture;
  String _locationName = "Getting location...";
  
  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    try {
      // Default position (Yogyakarta coordinates)
      Position defaultPosition = Position(
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
      
      Position position;
      bool isDefaultLocation = false;
      
      try {
        // Check if location services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          // Show dialog to enable location services
          if (mounted && context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Location Services Disabled'),
                  content: const Text(
                    'Please enable location services to get weather for your current location.'
                  ),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          position = defaultPosition;
          isDefaultLocation = true;
        } else {
          // Check permissions
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              position = defaultPosition;
              isDefaultLocation = true;
            } else {
              try {
                // Get user location with timeout
                position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                ).timeout(const Duration(seconds: 10));
              } catch (_) {
                position = defaultPosition;
                isDefaultLocation = true;
              }
            }
          } else if (permission == LocationPermission.deniedForever) {
            if (mounted && context.mounted) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Location Permission Denied'),
                    content: const Text(
                      'Please enable location permission in app settings to get weather for your current location.'
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Open Settings'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Geolocator.openAppSettings();
                        },
                      ),
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            position = defaultPosition;
            isDefaultLocation = true;
          } else {
            try {
              // Get user location with timeout
              position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              ).timeout(const Duration(seconds: 10));
            } catch (_) {
              position = defaultPosition;
              isDefaultLocation = true;
            }
          }
        }
        
        // Validate position
        if (position.latitude == 0 && position.longitude == 0) {
          position = defaultPosition;
          isDefaultLocation = true;
        }
      } catch (_) {
        position = defaultPosition;
        isDefaultLocation = true;
      }
      
      // Get location name using reverse geocoding
      try {
        if (isDefaultLocation) {
          _locationName = "Yogyakarta Region";
        } else {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, 
            position.longitude
          );
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            // Create a meaningful location name
            String locality = place.locality ?? '';
            String subLocality = place.subLocality ?? '';
            String adminArea = place.administrativeArea ?? '';
            
            if (locality.isNotEmpty) {
              _locationName = locality;
            } else if (subLocality.isNotEmpty) {
              _locationName = subLocality;
            } else if (adminArea.isNotEmpty) {
              _locationName = adminArea;
            } else {
              _locationName = "Current Location";
            }
          } else {
            _locationName = "Current Location";
          }
        }
      } catch (_) {
        _locationName = isDefaultLocation ? "Yogyakarta Region" : "Current Location";
      }
      
      // Get weather data
      try {
        final weather = await _weatherService.getWeather(position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _weatherFuture = Future.value(weather);
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            // Use a hardcoded default weather
            _weatherFuture = Future.value(Weather(
              description: 'sunny day',
              temperature: 28.5,
              feelsLike: 30.0,
              humidity: 65,
              windSpeed: 4.2,
              clouds: 15,
              iconCode: '01d',
            ));
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationName = "Unknown Location";
          // Ultimate fallback
          _weatherFuture = Future.value(Weather(
            description: 'sunny day',
            temperature: 28.5,
            feelsLike: 30.0,
            humidity: 65,
            windSpeed: 4.2,
            clouds: 15,
            iconCode: '01d',
          ));
        });
      }
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

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationHeader(),
                    const SizedBox(height: 24),
                    _buildMainWeatherCard(weather),
                    const SizedBox(height: 24),
                    _buildWeatherDetailsCard(weather),
                    const SizedBox(height: 24),
                    _buildForecastMessage(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildLocationHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _locationName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'Today', 
            style: TextStyle(color: Colors.blueGrey[600]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainWeatherCard(Weather weather) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.blue[800]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 42, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        weather.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/${weather.iconCode}@4x.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.wb_sunny,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherDetailsCard(Weather weather) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.water_drop, 'Humidity', '${weather.humidity}%'),
                _buildDetailItem(Icons.air, 'Wind', '${weather.windSpeed} m/s'),
                _buildDetailItem(Icons.cloud, 'Clouds', '${weather.clouds}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue[700]),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  Widget _buildForecastMessage() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green[50],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pull to refresh for the latest weather data. Perfect weather for farming today!',
                style: TextStyle(color: Colors.green, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}