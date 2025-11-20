import 'package:flutter/material.dart';
import 'package:famai/models/land_model.dart';
import 'package:famai/services/land_service.dart';
import 'package:famai/screens/map/land_details_form_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Screen to display detailed information about a land plot
class LandDetailScreen extends StatefulWidget {
  final String landId;
  
  const LandDetailScreen({
    super.key,
    required this.landId,
  });

  @override
  State<LandDetailScreen> createState() => _LandDetailScreenState();
}

class _LandDetailScreenState extends State<LandDetailScreen> {
  final LandService _landService = LandService();
  bool _isLoading = true;
  Land? _land;
  
  @override
  void initState() {
    super.initState();
    _loadLand();
  }
  
  Future<void> _loadLand() async {
    try {
      final land = await _landService.getLandById(widget.landId);
      
      if (mounted) {
        setState(() {
          _land = land;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load land: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _deleteLand() async {
    try {
      await _landService.deleteLand(widget.landId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Land deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return to land list with refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete land: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Land?'),
        content: const Text(
          'Are you sure you want to delete this land? This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLand();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToEdit() async {
    if (_land == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandDetailsFormScreen(land: _land!),
      ),
    );
    
    if (result == true) {
      _loadLand(); // Refresh land data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Land Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_land == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Land Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Land not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_land!.nickname),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: _getCenterCameraPosition(),
                polygons: {
                  _land!.toPolygon(selected: true),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                mapType: MapType.hybrid,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic info card
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _land!.nickname,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_land!.plantType != null && _land!.plantType!.isNotEmpty)
                                Chip(
                                  label: Text(_land!.plantType!),
                                  backgroundColor: Colors.green[100],
                                  labelStyle: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 12,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            Icons.calendar_today,
                            'Created',
                            _formatDate(_land!.createdAt),
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            LucideIcons.ruler,
                            'Size',
                            '${(_land!.areaSquareMeters / 10000).toStringAsFixed(2)} hectares',
                          ),
                          if (_land!.notes != null && _land!.notes!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'Notes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_land!.notes!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Analysis Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Weather summary
                  _buildAnalysisSummaryCard(
                    'Climate & Weather',
                    LucideIcons.cloud,
                    Colors.blue,
                    [
                      'Temperature: ${_land!.analysis.weather.temperature.toStringAsFixed(1)}°C',
                      'Annual Rainfall: ${_land!.analysis.weather.rainfall.toStringAsFixed(0)} mm',
                      'Humidity: ${_land!.analysis.weather.humidity.toStringAsFixed(0)}%',
                    ],
                    _land!.analysis.weather.summary,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Soil summary
                  _buildAnalysisSummaryCard(
                    'Soil Quality',
                    Icons.landscape,
                    Colors.brown,
                    [
                      'Quality: ${_land!.analysis.soilSuitability.quality}',
                      'pH Level: ${_land!.analysis.soilSuitability.ph}',
                      'Texture: ${_land!.analysis.soilSuitability.texture}',
                    ],
                    'This soil is suitable for a variety of crops, particularly ${_land!.analysis.recommendedCrops.take(2).join(", ")}.',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Water source summary
                  _buildAnalysisSummaryCard(
                    'Water Source',
                    LucideIcons.droplet,
                    Colors.blue,
                    [
                      'Name: ${_land!.analysis.waterSource.name}',
                      'Type: ${_land!.analysis.waterSource.type}',
                      'Distance: ${_land!.analysis.waterSource.distance.toStringAsFixed(0)} m',
                      'Reliability: ${_land!.analysis.waterSource.reliability.toStringAsFixed(0)}%',
                    ],
                    'Water source is ${_getReliabilityText(_land!.analysis.waterSource.reliability)}.',
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Recommended Crops',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recommended crops
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _land!.analysis.recommendedCrops.map((crop) {
                      return Chip(
                        label: Text(crop),
                        backgroundColor: Colors.green[100],
                        labelStyle: TextStyle(color: Colors.green[800]),
                        avatar: Icon(Icons.grass, color: Colors.green[800], size: 16),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  // FamCal integration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendarClock, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'View in FamCal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Check planting schedules and crop management',
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('FamCal integration coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  CameraPosition _getCenterCameraPosition() {
    if (_land == null) {
      return const CameraPosition(target: LatLng(0, 0), zoom: 14);
    }
    
    double latSum = 0, lngSum = 0;
    for (final point in _land!.coordinates) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    final centerLat = latSum / _land!.coordinates.length;
    final centerLng = lngSum / _land!.coordinates.length;
    
    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 16,
    );
  }
  
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAnalysisSummaryCard(
    String title,
    IconData icon,
    Color iconColor,
    List<String> details,
    String summary,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(detail),
            )).toList(),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _getReliabilityText(double reliability) {
    if (reliability >= 80) return 'highly reliable';
    if (reliability >= 60) return 'reliable';
    if (reliability >= 40) return 'moderately reliable';
    if (reliability >= 20) return 'somewhat unreliable';
    return 'unreliable';
  }
}
