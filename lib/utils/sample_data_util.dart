import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famai/models/field_data_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SampleDataUtil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Populates the database with sample fields for demonstration
  Future<void> populateSampleFields() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    final fieldsRef = _firestore.collection('users').doc(userId).collection('fields');
    
    // Check if sample fields already exist
    final existingFields = await fieldsRef.limit(1).get();
    if (existingFields.docs.isNotEmpty) {
      // Don't add samples if fields already exist
      return;
    }
    
    // Add sample fields
    for (var field in _getSampleFields()) {
      await fieldsRef.doc(field.id).set({
        'name': field.name,
        'areaHectares': field.areaHectares,
        'boundaries': field.boundaries.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
        'type': field.type.toString(),
        'productivityZones': field.productivityZones.map((zone) => {
          'id': zone.id,
          'level': zone.level.toString(),
          'yieldKgPerHa': zone.yieldKgPerHa,
          'boundaries': zone.boundaries.map((point) => {
            'latitude': point.latitude,
            'longitude': point.longitude,
          }).toList(),
        }).toList(),
        'waterLevel': field.waterLevel,
        'plantingDate': field.plantingDate.millisecondsSinceEpoch,
        'cropHealth': field.cropHealth.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  /// Creates sample conversation for chat demo
  Future<void> createSampleConversation() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    
    final conversationsRef = _firestore.collection('users').doc(userId).collection('conversations');
    
    // Check if sample conversation already exists
    final existingConversations = await conversationsRef.limit(1).get();
    if (existingConversations.docs.isNotEmpty) {
      // Don't add samples if conversations already exist
      return;
    }
    
    // Create a sample conversation
    final conversationRef = conversationsRef.doc();
    await conversationRef.set({
      'title': 'Farm Planning Advice',
      'lastMessage': 'What crops would grow well in sandy soil?',
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Add messages to the conversation
    final messagesRef = conversationRef.collection('messages');
    
    final messages = [
      {
        'author': 'user',
        'message': 'Hello, I need advice about my farm.',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'author': 'model',
        'message': 'Hi there! I\'d be happy to help with your farming questions. What would you like to know?',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      },
      {
        'author': 'user',
        'message': 'What crops would grow well in sandy soil?',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      },
      {
        'author': 'model',
        'message': 'Sandy soil is well-suited for crops like carrots, radishes, potatoes, lettuce, strawberries, and certain herbs. These plants thrive in the good drainage that sandy soil provides. You might also consider melons, cucumbers, and corn with proper fertilization. Would you like specific recommendations for your region?',
        'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      },
    ];
    
    for (var message in messages) {
      final timestamp = message['timestamp'] as DateTime;
      await messagesRef.add({
        'author': message['author'],
        'message': message['message'],
        'timestamp': Timestamp.fromDate(timestamp),
      });
    }
  }
  
  // Sample fields for demonstration
  List<FarmField> _getSampleFields() {
    return [
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
  }
}
