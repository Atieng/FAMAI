import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  // Google Maps API key - you would typically load this from environment variables
  // or a secure configuration file in a real production app
  static const String apiKey = 'AIzaSyBzQl6m4GtCUuHH2VDkmcXxXNtOXOx6uJk';
  
  // Default camera position centered on Yogyakarta, Indonesia
  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: LatLng(-7.7956, 110.3695),
    zoom: 14,
  );
  
  // Helper method to create field polygon with custom styling
  static Polygon createFieldPolygon({
    required String id,
    required List<LatLng> points,
    required Color fillColor,
    Color strokeColor = const Color(0xFF000000),
    int strokeWidth = 1,
    bool consumeTapEvents = true,
    void Function()? onTap,
  }) {
    return Polygon(
      polygonId: PolygonId(id),
      points: points,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      consumeTapEvents: consumeTapEvents,
      onTap: onTap,
    );
  }
  
  // Helper method to create styled marker
  static Marker createMarker({
    required String id,
    required LatLng position,
    String? title,
    String? snippet,
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
    void Function()? onTap,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      icon: icon,
      onTap: onTap,
    );
  }
  
  // Helper method to calculate center point of polygon
  static LatLng calculatePolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;
    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    return LatLng(
      latSum / points.length,
      lngSum / points.length,
    );
  }
  
  // Helper for field area calculation - simplified for demo
  static double calculateAreaInHectares(List<LatLng> points) {
    // In a real app, you would use a proper geodetic library for accurate calculations
    // This is just a simplified placeholder
    return 1.5; // Sample value in hectares
  }
}
