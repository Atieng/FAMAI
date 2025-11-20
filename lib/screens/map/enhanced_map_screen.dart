import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:famai/screens/map/bloc/map_bloc.dart';
import 'package:famai/screens/map/field_form_screen.dart';
import 'package:famai/services/weather_service.dart';
import 'package:famai/services/field_service.dart';
import 'package:famai/models/weather_model.dart';
import 'package:famai/models/field_data_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:famai/utils/map_utils.dart';
import 'package:famai/utils/sample_data_util.dart';

class EnhancedMapScreen extends StatefulWidget {
  const EnhancedMapScreen({super.key});

  @override
  State<EnhancedMapScreen> createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> with WidgetsBindingObserver {
  MapType _currentMapType = MapType.satellite;
  final WeatherService _weatherService = WeatherService();
  final FieldService _fieldService = FieldService();
  Weather? _currentWeather;
  final CameraPosition _initialPosition = MapUtils.defaultCameraPosition;
  GoogleMapController? _mapController;
  FarmField? _selectedField;
  bool _isShowingProductivityZones = false;
  List<FarmField> _fields = [];
  bool _isLoading = true;
  
  // Sample fields data - in a real app, this would come from Firestore or another database
  final List<FarmField> _sampleFields = [
    FarmField(
      id: 'tomatoes-field-1',
      name: 'Tomatoes Field',
      areaHectares: 1.2,
      boundaries: const [
        LatLng(-7.7946, 110.3685),
        LatLng(-7.7946, 110.3705),
        LatLng(-7.7966, 110.3705),
        LatLng(-7.7966, 110.3685),
      ],
      type: FieldType.tomatoes,
      productivityZones: [
        ProductivityZone(
          id: 'zone-1',
          level: ZoneProductivity.veryHigh,
          yieldKgPerHa: 100.0,
          boundaries: const [
            LatLng(-7.7946, 110.3685),
            LatLng(-7.7946, 110.3695),
            LatLng(-7.7956, 110.3695),
            LatLng(-7.7956, 110.3685),
          ],
        ),
        ProductivityZone(
          id: 'zone-2',
          level: ZoneProductivity.high,
          yieldKgPerHa: 76.0,
          boundaries: const [
            LatLng(-7.7946, 110.3695),
            LatLng(-7.7946, 110.3705),
            LatLng(-7.7956, 110.3705),
            LatLng(-7.7956, 110.3695),
          ],
        ),
        ProductivityZone(
          id: 'zone-3',
          level: ZoneProductivity.average,
          yieldKgPerHa: 24.0,
          boundaries: const [
            LatLng(-7.7956, 110.3685),
            LatLng(-7.7956, 110.3695),
            LatLng(-7.7966, 110.3695),
            LatLng(-7.7966, 110.3685),
          ],
        ),
      ],
      waterLevel: 97,
      plantingDate: DateTime.now().subtract(const Duration(days: 30)),
      cropHealth: CropHealth.good,
    ),
    FarmField(
      id: 'corn-field-1',
      name: 'Corn Field',
      areaHectares: 0.8,
      boundaries: const [
        LatLng(-7.7976, 110.3685),
        LatLng(-7.7976, 110.3700),
        LatLng(-7.7986, 110.3700),
        LatLng(-7.7986, 110.3685),
      ],
      type: FieldType.corn,
      productivityZones: [
        ProductivityZone(
          id: 'zone-1',
          level: ZoneProductivity.high,
          yieldKgPerHa: 85.0,
          boundaries: const [
            LatLng(-7.7976, 110.3685),
            LatLng(-7.7976, 110.3700),
            LatLng(-7.7981, 110.3700),
            LatLng(-7.7981, 110.3685),
          ],
        ),
        ProductivityZone(
          id: 'zone-2',
          level: ZoneProductivity.average,
          yieldKgPerHa: 45.0,
          boundaries: const [
            LatLng(-7.7981, 110.3685),
            LatLng(-7.7981, 110.3700),
            LatLng(-7.7986, 110.3700),
            LatLng(-7.7986, 110.3685),
          ],
        ),
      ],
      waterLevel: 75,
      plantingDate: DateTime.now().subtract(const Duration(days: 45)),
      cropHealth: CropHealth.good,
    ),
    FarmField(
      id: 'lettuce-field-1',
      name: 'Lettuce Field',
      areaHectares: 0.5,
      boundaries: const [
        LatLng(-7.7946, 110.3665),
        LatLng(-7.7946, 110.3675),
        LatLng(-7.7956, 110.3675),
        LatLng(-7.7956, 110.3665),
      ],
      type: FieldType.lettuce,
      productivityZones: [
        ProductivityZone(
          id: 'zone-1',
          level: ZoneProductivity.average,
          yieldKgPerHa: 35.0,
          boundaries: const [
            LatLng(-7.7946, 110.3665),
            LatLng(-7.7946, 110.3675),
            LatLng(-7.7956, 110.3675),
            LatLng(-7.7956, 110.3665),
          ],
        ),
      ],
      waterLevel: 80,
      plantingDate: DateTime.now().subtract(const Duration(days: 15)),
      cropHealth: CropHealth.excellent,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchWeather();
    _loadFields();
  }
  
  Future<void> _loadFields() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Add sample data for demonstration
      final sampleData = SampleDataUtil();
      await sampleData.populateSampleFields();
      
      // Subscribe to field updates
      _fieldService.getFields().listen((fields) {
        if (mounted) {
          setState(() {
            _fields = fields;
            _isLoading = false;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            // On error, use sample fields for demo
            _fields = _sampleFields;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _fields = _sampleFields;
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _mapController != null) {
      setState(() {}); // Refresh map when app is resumed
    }
  }
  
  Future<void> _fetchWeather() async {
    try {
      final weather = await _weatherService.getWeather(-7.7956, 110.3695);
      setState(() {
        _currentWeather = weather;
      });
    } catch (e) {
      // Handle weather fetch error
      debugPrint('Failed to fetch weather: $e');
    }
  }

  Set<Polygon> _buildFieldPolygons() {
    final polygons = <Polygon>{};
    
    // Use loaded fields if available, otherwise fall back to sample fields
    final fieldsToShow = _fields.isNotEmpty ? _fields : _sampleFields;
    
    for (var field in fieldsToShow) {
      // Only show productivity zones for the selected field
      if (_isShowingProductivityZones && _selectedField?.id == field.id) {
        for (var zone in field.productivityZones) {
          polygons.add(
            Polygon(
              polygonId: PolygonId('zone-${field.id}-${zone.id}'),
              points: zone.boundaries,
              fillColor: zone.color.withOpacity(0.5),
              strokeColor: zone.color,
              strokeWidth: 1,
            ),
          );
        }
      } else {
        Color fillColor;
        switch (field.type) {
          case FieldType.tomatoes:
            fillColor = Colors.red.withOpacity(0.3);
            break;
          case FieldType.lettuce:
            fillColor = Colors.green.withOpacity(0.3);
            break;
          case FieldType.corn:
            fillColor = Colors.yellow.withOpacity(0.3);
            break;
          case FieldType.wheat:
            fillColor = Colors.amber.withOpacity(0.3);
            break;
          case FieldType.rice:
            fillColor = Colors.lightGreen.withOpacity(0.3);
            break;
          default:
            fillColor = Colors.blue.withOpacity(0.3);
        }
        
        polygons.add(
          Polygon(
            polygonId: PolygonId(field.id),
            points: field.boundaries,
            fillColor: fillColor,
            strokeColor: Colors.black,
            strokeWidth: 1,
            consumeTapEvents: true,
            onTap: () {
              setState(() {
                _selectedField = field;
              });
            },
          ),
        );
      }
    }
    
    return polygons;
  }
  
  Set<Marker> _buildFieldMarkers() {
    final markers = <Marker>{};
    
    // Use loaded fields if available, otherwise fall back to sample fields
    final fieldsToShow = _fields.isNotEmpty ? _fields : _sampleFields;
    
    for (var field in fieldsToShow) {
      // Calculate the center of the field
      double latSum = 0;
      double lngSum = 0;
      for (var point in field.boundaries) {
        latSum += point.latitude;
        lngSum += point.longitude;
      }
      final center = LatLng(
        latSum / field.boundaries.length,
        lngSum / field.boundaries.length,
      );
      
      markers.add(
        Marker(
          markerId: MarkerId('marker-${field.id}'),
          position: center,
          infoWindow: InfoWindow(
            title: field.name,
            snippet: '${field.areaHectares.toStringAsFixed(1)} ha',
          ),
        ),
      );
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: Scaffold(
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              mapType: _currentMapType,
              polygons: _buildFieldPolygons(),
              markers: _buildFieldMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildWeatherWidget(),
            ),
            if (_selectedField != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFieldInfoPanel(),
              ),
            Positioned(
              bottom: 90,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: "addFieldFab",
                    onPressed: () => _navigateToFieldForm(null),
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: "mapTypeFab",
                    onPressed: () => _showMapTypeSelector(),
                    child: const Icon(Icons.layers),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: _currentWeather == null
          ? const CircularProgressIndicator()
          : Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        const Text('Yogyakarta, Indonesia'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '+${_currentWeather!.temperature.round()}°',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_currentWeather!.feelsLike.round()}°',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                ),
              ],
            ),
    );
  }
  
  Widget _buildFieldInfoPanel() {
    if (_selectedField == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedField!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedField = null;
                    _isShowingProductivityZones = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBox(
                title: 'Size',
                value: '${_selectedField!.areaHectares.toStringAsFixed(1)} ha',
                icon: LucideIcons.ruler,
              ),
              _buildInfoBox(
                title: 'Water Level',
                value: '${_selectedField!.waterLevel.toStringAsFixed(0)}%',
                icon: LucideIcons.droplet,
              ),
              _buildInfoBox(
                title: 'Health',
                value: StringCaseUtils.capitalize(_selectedField!.cropHealth.name),
                icon: LucideIcons.heart,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isShowingProductivityZones = !_isShowingProductivityZones;
                  });
                },
                icon: Icon(_isShowingProductivityZones ? LucideIcons.eyeOff : LucideIcons.eye),
                label: Text(_isShowingProductivityZones ? 'Hide Zones' : 'Show Productivity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isShowingProductivityZones ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showWaterIndicatorDialog(),
                icon: const Icon(LucideIcons.droplet),
                label: const Text('Water'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedField != null) {
                    _navigateToFieldForm(_selectedField);
                  }
                },
                icon: const Icon(LucideIcons.edit),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (_isShowingProductivityZones) ...[
            const SizedBox(height: 20),
            _buildProductivityZonesPanel(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoBox({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 8),
          Text(
            title,
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
      ),
    );
  }
  
  Widget _buildProductivityZonesPanel() {
    if (_selectedField == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productivity Zones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 3; i <= 9; i++)
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: i == 7 ? Colors.green : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$i',
                    style: TextStyle(
                      color: i == 7 ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildProductivityLegendItem(ZoneProductivity.veryHigh, 'Very High'),
            _buildProductivityLegendItem(ZoneProductivity.high, 'High'),
            _buildProductivityLegendItem(ZoneProductivity.average, 'Average'),
            _buildProductivityLegendItem(ZoneProductivity.low, 'Low'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildYieldBox('100kg/h', '1.8ha'),
            _buildYieldBox('76kg/h', '1.8ha'),
            _buildYieldBox('24kg/h', '1.8ha'),
            _buildYieldBox('0kg/h', '-'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Standard Rate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  ),
                  child: const Text('100'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                  ),
                  child: const Text(
                    'Kg/ha',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProductivityLegendItem(ZoneProductivity level, String label) {
    Color dotColor;
    switch (level) {
      case ZoneProductivity.veryHigh:
        dotColor = Colors.green;
        break;
      case ZoneProductivity.high:
        dotColor = Colors.lightGreen;
        break;
      case ZoneProductivity.average:
        dotColor = Colors.yellow;
        break;
      case ZoneProductivity.low:
        dotColor = Colors.grey;
        break;
      default:
        dotColor = Colors.red;
    }
    
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  
  Widget _buildYieldBox(String yield, String area) {
    return Column(
      children: [
        Text(yield, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(area, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  void _showMapTypeSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Normal'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.normal;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite),
              title: const Text('Satellite'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.satellite;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.terrain),
              title: const Text('Terrain'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.terrain;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Hybrid'),
              onTap: () {
                setState(() {
                  _currentMapType = MapType.hybrid;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _navigateToFieldForm(FarmField? field) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldFormScreen(field: field),
      ),
    );
    
    if (result == true) {
      // Field was saved, refresh data
      _loadFields();
    }
  }
  
  void _showWaterIndicatorDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Water Indicator',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _selectedField!.waterLevel / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 30,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('0%'),
                  Text('${_selectedField!.waterLevel.toStringAsFixed(0)}%'),
                  const Text('100%'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Helper extension to capitalize string
// Using StringCaseUtils to avoid conflicts with field_form_screen.dart
class StringCaseUtils {
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return "${input[0].toUpperCase()}${input.substring(1)}";
  }
}
