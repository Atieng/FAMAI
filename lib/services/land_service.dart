import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:famai/models/land_model.dart';

/// Service to manage land operations in Firestore
class LandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Get reference to lands collection for the current user
  CollectionReference<Map<String, dynamic>> get _landsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).collection('lands');
  }
  
  // Stream all lands for the current user
  Stream<List<Land>> getLands() {
    try {
      return _landsRef
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Land.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      // Return empty list if error occurs
      print('Error getting lands: $e');
      return Stream.value([]);
    }
  }
  
  // Get a single land by ID
  Future<Land?> getLandById(String id) async {
    try {
      final doc = await _landsRef.doc(id).get();
      if (doc.exists) {
        return Land.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting land: $e');
      return null;
    }
  }
  
  // Create or update a land
  Future<String> saveLand(Land land) async {
    try {
      final data = land.toFirestore();
      
      if (land.id == 'new') {
        // New land - generate ID
        final String newId = _uuid.v4();
        await _landsRef.doc(newId).set(data);
        return newId;
      } else {
        // Update existing land
        await _landsRef.doc(land.id).update(data);
        return land.id;
      }
    } catch (e) {
      print('Error saving land: $e');
      rethrow;
    }
  }
  
  // Delete a land
  Future<void> deleteLand(String id) async {
    try {
      await _landsRef.doc(id).delete();
    } catch (e) {
      print('Error deleting land: $e');
      rethrow;
    }
  }
  
  // Calculate area of polygon in square meters
  double calculateAreaInSquareMeters(List<LatLng> coordinates) {
    if (coordinates.length < 3) return 0.0;
    
    final points = coordinates
        .map((point) => maps_toolkit.LatLng(point.latitude, point.longitude))
        .toList();
    
    return maps_toolkit.SphericalUtil.computeArea(points).toDouble();
  }
  
  // Analyze land - in a real app, this would call external APIs
  // For now, we'll generate mock data
  Future<LandAnalysis> analyzeLand(List<LatLng> coordinates) async {
    try {
      // Calculate centroid of the polygon for simulated location-based analysis
      double lat = 0, lng = 0;
      for (final point in coordinates) {
        lat += point.latitude;
        lng += point.longitude;
      }
      lat /= coordinates.length;
      lng /= coordinates.length;
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate mock data
      return LandAnalysis(
        weather: Weather(
          temperature: 24.5 + (lat.abs() % 5),
          rainfall: 800 + (lng.abs() % 400),
          humidity: 65 + (lat.abs() % 20),
          summary: 'Moderate rainfall with warm temperatures',
          monthlyBreakdown: 'Jan: Dry, Feb-Apr: Rainy, May-Aug: Dry, Sep-Dec: Moderate rainfall',
        ),
        waterSource: WaterSource(
          name: 'River Alpha',
          distance: 350 + (lat.abs() * 100) % 500,
          type: 'River',
          reliability: 85.0,
        ),
        airCondition: AirCondition(
          quality: 87.5,
          description: 'Good air quality with occasional pollution during dry seasons',
          pollutants: {
            'PM2.5': 12.3,
            'PM10': 25.7,
            'NO2': 8.5,
            'O3': 34.2,
          },
        ),
        soilSuitability: SoilSuitability(
          quality: 'Good',
          nutrients: {
            'Nitrogen': 65.2,
            'Phosphorus': 45.8,
            'Potassium': 72.1,
            'Organic Matter': 3.8,
          },
          ph: 6.4,
          texture: 'Clay Loam',
        ),
        recommendedCrops: [
          'Maize',
          'Tomatoes',
          'Lettuce',
          'Beans',
          'Sweet Potatoes',
        ],
      );
    } catch (e) {
      print('Error analyzing land: $e');
      return LandAnalysis.defaultAnalysis();
    }
  }
  
  // Get list of plant types (would be synchronized with FamCal in a real app)
  Future<List<String>> getPlantTypes() async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      return [
        'Maize',
        'Beans',
        'Tomatoes',
        'Lettuce',
        'Sweet Potatoes',
        'Cabbage',
        'Carrots',
        'Onions',
        'Rice',
        'Wheat',
        'Coffee',
        'Tea',
      ];
    } catch (e) {
      print('Error getting plant types: $e');
      return [];
    }
  }
}
