import 'package:flutter/material.dart';
import 'package:famai/models/land_model.dart';
import 'package:famai/services/land_service.dart';
import 'package:famai/screens/map/land_details_form_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Screen to display land analysis results
class LandAnalysisScreen extends StatefulWidget {
  final Land land;
  
  const LandAnalysisScreen({
    super.key,
    required this.land,
  });

  @override
  State<LandAnalysisScreen> createState() => _LandAnalysisScreenState();
}

class _LandAnalysisScreenState extends State<LandAnalysisScreen> {
  final LandService _landService = LandService();
  bool _isAnalyzing = true;
  late Land _land;
  
  @override
  void initState() {
    super.initState();
    _land = widget.land;
    _analyzeField();
  }
  
  Future<void> _analyzeField() async {
    try {
      final analysis = await _landService.analyzeLand(_land.coordinates);
      
      if (mounted) {
        setState(() {
          _land = _land.copyWith(analysis: analysis);
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Analysis'),
      ),
      body: _isAnalyzing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 24),
                  Text(
                    'Analyzing Land...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Checking soil, climate, and water sources'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMapPreview(),
                    const SizedBox(height: 24),
                    _buildLandAreaCard(),
                    const SizedBox(height: 16),
                    _buildWeatherCard(),
                    const SizedBox(height: 16),
                    _buildSoilCard(),
                    const SizedBox(height: 16),
                    _buildWaterSourceCard(),
                    const SizedBox(height: 16),
                    _buildAirQualityCard(),
                    const SizedBox(height: 16),
                    _buildRecommendedCropsCard(),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _navigateToDetailsForm(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Continue to Details',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildMapPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: _getCenterCameraPosition(),
        polygons: {
          Polygon(
            polygonId: const PolygonId('land_polygon'),
            points: _land.coordinates,
            strokeWidth: 2,
            strokeColor: Colors.green,
            fillColor: Colors.green.withOpacity(0.3),
          ),
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: false,
        zoomGesturesEnabled: false,
        tiltGesturesEnabled: false,
        compassEnabled: false,
        mapType: MapType.hybrid,
      ),
    );
  }
  
  CameraPosition _getCenterCameraPosition() {
    // Calculate center of the polygon
    double latSum = 0, lngSum = 0;
    for (final point in _land.coordinates) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    final centerLat = latSum / _land.coordinates.length;
    final centerLng = lngSum / _land.coordinates.length;
    
    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 15,
    );
  }
  
  Widget _buildLandAreaCard() {
    // Convert square meters to hectares
    final areaHectares = _land.areaSquareMeters / 10000;
    final areaAcres = _land.areaSquareMeters / 4046.86;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.ruler, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Land Area',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAreaItem(
                  value: areaHectares.toStringAsFixed(2),
                  unit: 'hectares',
                  icon: Icons.crop_square,
                ),
                _buildAreaItem(
                  value: areaAcres.toStringAsFixed(2),
                  unit: 'acres',
                  icon: Icons.crop_square,
                ),
                _buildAreaItem(
                  value: _land.areaSquareMeters.toStringAsFixed(0),
                  unit: 'm²',
                  icon: Icons.square_foot,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAreaItem({
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeatherCard() {
    final weather = _land.analysis.weather;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.cloud, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Climate & Weather',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWeatherItem(
                  value: '${weather.temperature.toStringAsFixed(1)}°C',
                  label: 'Temp',
                  icon: LucideIcons.thermometer,
                  iconColor: Colors.red,
                ),
                _buildWeatherItem(
                  value: '${weather.rainfall.toStringAsFixed(0)} mm',
                  label: 'Annual Rainfall',
                  icon: LucideIcons.cloudRain,
                  iconColor: Colors.blue,
                ),
                _buildWeatherItem(
                  value: '${weather.humidity.toStringAsFixed(0)}%',
                  label: 'Humidity',
                  icon: LucideIcons.droplet,
                  iconColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Summary:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(weather.summary),
            const SizedBox(height: 12),
            const Text(
              'Monthly Breakdown:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(weather.monthlyBreakdown),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherItem({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSoilCard() {
    final soil = _land.analysis.soilSuitability;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.landscape, color: Colors.brown[600]),
                const SizedBox(width: 8),
                const Text(
                  'Soil Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSoilProperty('Quality', soil.quality),
                _buildSoilProperty('pH Level', soil.ph.toString()),
                _buildSoilProperty('Texture', soil.texture),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Nutrient Levels:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildNutrientLevels(soil.nutrients),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSoilProperty(String name, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNutrientLevels(Map<String, double> nutrients) {
    return Column(
      children: nutrients.entries.map((entry) {
        final nutrient = entry.key;
        final level = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$nutrient: ${level.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: level / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  level > 70 ? Colors.green : (level > 30 ? Colors.orange : Colors.red),
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildWaterSourceCard() {
    final water = _land.analysis.waterSource;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.droplet, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Water Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                water.type == 'River' 
                    ? LucideIcons.waves 
                    : (water.type == 'Lake' ? LucideIcons.umbrella : LucideIcons.droplets),
                color: Colors.blue,
              ),
              title: Text(water.name),
              subtitle: Text(water.type),
              trailing: Text(
                '${water.distance.toStringAsFixed(0)} m',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reliability:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: water.reliability / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                water.reliability > 70 ? Colors.green : (water.reliability > 40 ? Colors.orange : Colors.red),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Text(
              '${water.reliability.toStringAsFixed(0)}% Reliable',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAirQualityCard() {
    final air = _land.analysis.airCondition;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.wind, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  'Air Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getAirQualityColor(air.quality),
                  ),
                  child: Center(
                    child: Text(
                      air.quality.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAirQualityText(air.quality),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(air.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pollutants:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildPollutantsList(air.pollutants),
          ],
        ),
      ),
    );
  }
  
  Color _getAirQualityColor(double quality) {
    if (quality >= 80) return Colors.green;
    if (quality >= 60) return Colors.lightGreen;
    if (quality >= 40) return Colors.orange;
    if (quality >= 20) return Colors.deepOrange;
    return Colors.red;
  }
  
  String _getAirQualityText(double quality) {
    if (quality >= 80) return 'Excellent';
    if (quality >= 60) return 'Good';
    if (quality >= 40) return 'Moderate';
    if (quality >= 20) return 'Poor';
    return 'Very Poor';
  }
  
  Widget _buildPollutantsList(Map<String, double> pollutants) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: pollutants.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildRecommendedCropsCard() {
    final crops = _land.analysis.recommendedCrops;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grass, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Recommended Crops',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: crops.map((crop) {
                return Chip(
                  label: Text(crop),
                  backgroundColor: Colors.green[100],
                  labelStyle: TextStyle(color: Colors.green[800]),
                  avatar: Icon(LucideIcons.leaf, color: Colors.green[800], size: 16),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToDetailsForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandDetailsFormScreen(land: _land),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context, true); // Return to land list with success
    }
  }
}
