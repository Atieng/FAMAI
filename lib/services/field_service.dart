import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:famai/models/field_data_model.dart';
import 'package:uuid/uuid.dart';

class FieldService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Get reference to the user's fields collection
  CollectionReference<Map<String, dynamic>> get _fieldsRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(userId).collection('fields');
  }

  // Stream all fields for the current user
  Stream<List<FarmField>> getFields() {
    try {
      return _fieldsRef.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return _deserializeField(data);
        }).toList();
      });
    } catch (e) {
      // Return empty list with sample data for demonstration if error occurs
      return Stream.value(_getSampleFields());
    }
  }

  // Get a specific field by ID
  Stream<FarmField?> getFieldById(String fieldId) {
    try {
      return _fieldsRef.doc(fieldId).snapshots().map((doc) {
        if (!doc.exists) return null;
        final data = doc.data()!;
        data['id'] = doc.id;
        return _deserializeField(data);
      });
    } catch (e) {
      // Return null if error occurs
      return Stream.value(null);
    }
  }

  // Save a field to Firestore
  Future<void> saveField(FarmField field) async {
    try {
      final Map<String, dynamic> data = _serializeField(field);
      
      if (field.id.isEmpty) {
        // New field, create with generated ID
        await _fieldsRef.add(data);
      } else {
        // Update existing field
        await _fieldsRef.doc(field.id).set(data, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a field
  Future<void> deleteField(String fieldId) async {
    try {
      await _fieldsRef.doc(fieldId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Convert Firestore data to FarmField object
  FarmField _deserializeField(Map<String, dynamic> data) {
    try {
      final List<LatLng> boundaries = (data['boundaries'] as List?)
          ?.map((point) => LatLng(
                (point['latitude'] as num).toDouble(),
                (point['longitude'] as num).toDouble(),
              ))
          .toList() ??
          [];

      final List<ProductivityZone> zones = (data['productivityZones'] as List?)
          ?.map((zone) => ProductivityZone(
                id: zone['id'] as String? ?? _uuid.v4(),
                level: _parseProductivityLevel(zone['level'] as String?),
                yieldKgPerHa: (zone['yieldKgPerHa'] as num?)?.toDouble() ?? 0.0,
                boundaries: (zone['boundaries'] as List?)
                    ?.map((point) => LatLng(
                          (point['latitude'] as num).toDouble(),
                          (point['longitude'] as num).toDouble(),
                        ))
                    .toList() ??
                    [],
              ))
          .toList() ??
          [];

      return FarmField(
        id: data['id'] as String? ?? _uuid.v4(),
        name: data['name'] as String? ?? 'Unnamed Field',
        areaHectares: (data['areaHectares'] as num?)?.toDouble() ?? 0.0,
        boundaries: boundaries,
        type: _parseFieldType(data['type'] as String?),
        productivityZones: zones,
        waterLevel: (data['waterLevel'] as num?)?.toDouble() ?? 75.0,
        plantingDate: data['plantingDate'] != null
            ? (data['plantingDate'] is Timestamp
                ? (data['plantingDate'] as Timestamp).toDate()
                : DateTime.fromMillisecondsSinceEpoch(data['plantingDate'] as int))
            : DateTime.now(),
        cropHealth: _parseCropHealth(data['cropHealth'] as String?),
      );
    } catch (e) {
      // If there's an error parsing, return a default field
      return FarmField(
        id: data['id'] as String? ?? _uuid.v4(),
        name: 'Error Field',
        areaHectares: 0.0,
        boundaries: const [],
        type: FieldType.other,
        productivityZones: const [],
        waterLevel: 0.0,
        plantingDate: DateTime.now(),
        cropHealth: CropHealth.unknown,
      );
    }
  }

  // Convert FarmField object to Firestore data
  Map<String, dynamic> _serializeField(FarmField field) {
    return {
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
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  FieldType _parseFieldType(String? typeStr) {
    if (typeStr == null) return FieldType.other;
    
    for (var type in FieldType.values) {
      if (type.toString() == typeStr) {
        return type;
      }
    }
    
    return FieldType.other;
  }

  ZoneProductivity _parseProductivityLevel(String? levelStr) {
    if (levelStr == null) return ZoneProductivity.average;
    
    for (var level in ZoneProductivity.values) {
      if (level.toString() == levelStr) {
        return level;
      }
    }
    
    return ZoneProductivity.average;
  }

  CropHealth _parseCropHealth(String? healthStr) {
    if (healthStr == null) return CropHealth.unknown;
    
    for (var health in CropHealth.values) {
      if (health.toString() == healthStr) {
        return health;
      }
    }
    
    return CropHealth.unknown;
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
    ];
  }
}
