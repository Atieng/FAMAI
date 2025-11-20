import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:famai/models/land_model.dart';
import 'package:famai/services/land_service.dart';
import 'package:famai/screens/map/land_analysis_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';

/// Screen for adding a new land plot with polygon drawing
class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final LandService _landService = LandService();
  final TextEditingController _searchController = TextEditingController();
  final List<LatLng> _points = [];
  
  GoogleMapController? _mapController;
  Set<Polygon> _polygons = {};
  Set<Marker> _markers = {};
  
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14.0,
  );
  
  bool _isLoadingLocation = true;
  bool _isDrawingMode = true;
  bool _hasPolygon = false;
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  // Get user's current location
  Future<void> _getUserLocation() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;
    LocationData locationData;
    
    try {
      // Check if location services are enabled
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }
      
      // Check if we have permission
      permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }
      
      // Get the current location
      locationData = await location.getLocation();
      
      // Update camera position
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 16.0,
        );
        _isLoadingLocation = false;
      });
      
      // Move camera to user's location when map is ready
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(locationData.latitude!, locationData.longitude!),
            16.0,
          ),
        );
      }
    } catch (e) {
      print('Error getting user location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Handle map taps to create polygon
  void _onMapTap(LatLng point) {
    if (!_isDrawingMode) return;
    
    setState(() {
      // Add the point
      _points.add(point);
      
      // Add marker for the point
      _markers.add(
        Marker(
          markerId: MarkerId('point_${_points.length - 1}'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      
      // Update polygon if we have at least 3 points
      if (_points.length >= 3) {
        _polygons = {
          Polygon(
            polygonId: const PolygonId('land_polygon'),
            points: _points,
            strokeWidth: 2,
            strokeColor: Colors.green,
            fillColor: Colors.green.withOpacity(0.3),
          ),
        };
        
        _hasPolygon = true;
      }
    });
  }
  
  void _removeLastPoint() {
    if (_points.isEmpty) return;
    
    setState(() {
      // Remove last point
      _points.removeLast();
      
      // Remove marker
      _markers = _markers.where((m) => 
        m.markerId.value != 'point_${_points.length}'
      ).toSet();
      
      // Update polygon
      if (_points.length >= 3) {
        _polygons = {
          Polygon(
            polygonId: const PolygonId('land_polygon'),
            points: _points,
            strokeWidth: 2,
            strokeColor: Colors.green,
            fillColor: Colors.green.withOpacity(0.3),
          ),
        };
      } else {
        _polygons = {};
        _hasPolygon = false;
      }
    });
  }
  
  void _clearPolygon() {
    setState(() {
      _points.clear();
      _markers = {};
      _polygons = {};
      _hasPolygon = false;
    });
  }
  
  void _toggleDrawingMode() {
    setState(() {
      _isDrawingMode = !_isDrawingMode;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDrawingMode 
            ? 'Drawing mode enabled. Tap on the map to draw.' 
            : 'Drawing mode disabled. You can pan and zoom the map.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _proceedToAnalysis() async {
    if (_points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please draw a complete polygon with at least 3 points.'),
        ),
      );
      return;
    }
    
    // Calculate area
    final area = _landService.calculateAreaInSquareMeters(_points);
    
    // Create a new land object
    final land = Land(
      id: 'new',
      nickname: 'New Land',
      coordinates: List.from(_points),
      areaSquareMeters: area,
      analysis: LandAnalysis.defaultAnalysis(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Navigate to analysis screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandAnalysisScreen(land: land),
      ),
    );
    
    if (result == true) {
      Navigator.pop(context, true); // Return to land list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Land Boundary'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info),
            onPressed: () {
              _showInstructions();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: _initialPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.hybrid, // Satellite with labels
                  markers: _markers,
                  polygons: _polygons,
                  onTap: _onMapTap,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
          
          // Search bar at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: const Icon(LucideIcons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (value) {
                  // TODO: Implement place search
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search feature coming soon')),
                  );
                },
              ),
            ),
          ),
          
          // Controls at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Drawing tools
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(_isDrawingMode ? LucideIcons.pencil : LucideIcons.move),
                        tooltip: _isDrawingMode ? 'Drawing Mode' : 'Pan Mode',
                        onPressed: _toggleDrawingMode,
                        color: _isDrawingMode ? Colors.green : Colors.grey,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.undo),
                        tooltip: 'Remove Last Point',
                        onPressed: _points.isEmpty ? null : _removeLastPoint,
                        color: _points.isEmpty ? Colors.grey : Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash),
                        tooltip: 'Clear All',
                        onPressed: _points.isEmpty ? null : _clearPolygon,
                        color: _points.isEmpty ? Colors.grey : Colors.red,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.locateFixed),
                        tooltip: 'My Location',
                        onPressed: _getUserLocation,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Next button
                ElevatedButton(
                  onPressed: _hasPolygon ? _proceedToAnalysis : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Analyze Land'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Map Your Land'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. Tap on the map to start drawing your land boundary'),
              SizedBox(height: 8),
              Text('2. Add at least 3 points to create a polygon'),
              SizedBox(height: 8),
              Text('3. Use the undo button to remove the last point'),
              SizedBox(height: 8),
              Text('4. Use the clear button to start over'),
              SizedBox(height: 8),
              Text('5. Toggle drawing mode to pan/zoom the map'),
              SizedBox(height: 8),
              Text('6. When finished, tap "Analyze Land"'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
