import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:famai/services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final List<LatLng> _polygonPoints = [];
  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  final _mapService = MapService();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLocate();
  }

  Future<void> _requestPermissionAndLocate() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ));
      } catch (e) {
        print('Error getting location: $e');
      }
    } else {
      print('Location permission denied');
    }
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _polygonPoints.add(point);
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
  }

  void _createPolygon() async {
    if (_polygonPoints.length > 2) {
      setState(() {
        final polygon = Polygon(
          polygonId: PolygonId('farm_boundary_${_polygons.length}'),
          points: List.from(_polygonPoints),
          strokeWidth: 2,
          strokeColor: Colors.green,
          fillColor: Colors.green.withOpacity(0.3),
        );
        _polygons.add(polygon);
      });

      await _mapService.saveFarmBoundary(_polygonPoints);

      final area = _computeArea(_polygonPoints);
      final areaInHectares = area / 10000;

      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Farm Analysis'),
          content: Text('Your farm area is ${areaInHectares.toStringAsFixed(2)} hectares.\n\nWe are working on providing more insights with AI.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _clearPoints() {
    setState(() {
      _polygonPoints.clear();
      _markers.clear();
    });
  }

  double _computeArea(List<LatLng> points) {
    double area = 0.0;
    if (points.length < 3) return 0.0;

    for (int i = 0; i < points.length; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % points.length];
      area += (p1.longitude * p2.latitude - p2.longitude * p1.latitude);
    }

    area = area.abs() / 2.0;
    // Convert to square meters: 1 degree of latitude is about 111 km, and longitude varies but we assume same.
    // This is a very rough estimate and not accurate for large areas or near the poles.
    return area * (111000 * 111000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Famap')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kInitialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _onMapTapped,
            polygons: _polygons,
            markers: _markers,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _createPolygon,
                  child: const Icon(Icons.check),
                  heroTag: 'create_polygon',
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _clearPoints,
                  child: const Icon(Icons.clear),
                  backgroundColor: Colors.red,
                  heroTag: 'clear_points',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
