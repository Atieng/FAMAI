import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmField {
  final String id;
  final String name;
  final double areaHectares;
  final List<LatLng> boundaries;
  final FieldType type;
  final List<ProductivityZone> productivityZones;
  final double waterLevel; // 0-100%
  final DateTime plantingDate;
  final CropHealth cropHealth;

  FarmField({
    required this.id,
    required this.name,
    required this.areaHectares,
    required this.boundaries,
    required this.type,
    required this.productivityZones,
    required this.waterLevel,
    required this.plantingDate,
    required this.cropHealth,
  });

  // Create a polygon from the field boundaries
  Polygon toPolygon({Color? fillColor, Color? strokeColor}) {
    return Polygon(
      polygonId: PolygonId(id),
      points: boundaries,
      fillColor: fillColor ?? Colors.green.withOpacity(0.3),
      strokeColor: strokeColor ?? Colors.green,
      strokeWidth: 2,
    );
  }

  // For Firebase storage/retrieval
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'areaHectares': areaHectares,
      'boundaries': boundaries.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude
      }).toList(),
      'type': type.toString(),
      'productivityZones': productivityZones.map((zone) => zone.toMap()).toList(),
      'waterLevel': waterLevel,
      'plantingDate': plantingDate.millisecondsSinceEpoch,
      'cropHealth': cropHealth.toString(),
    };
  }

  // Create a Field from a map
  factory FarmField.fromMap(Map<String, dynamic> map) {
    final type = FieldType.values.firstWhere(
      (e) => e.toString() == map['type'],
      orElse: () => FieldType.other,
    );
    
    final health = CropHealth.values.firstWhere(
      (e) => e.toString() == map['cropHealth'],
      orElse: () => CropHealth.unknown,
    );
    
    return FarmField(
      id: map['id'],
      name: map['name'],
      areaHectares: map['areaHectares'],
      boundaries: List<Map<String, dynamic>>.from(map['boundaries'])
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
      type: type,
      productivityZones: List<Map<String, dynamic>>.from(map['productivityZones'])
          .map((zone) => ProductivityZone.fromMap(zone))
          .toList(),
      waterLevel: map['waterLevel'],
      plantingDate: DateTime.fromMillisecondsSinceEpoch(map['plantingDate']),
      cropHealth: health,
    );
  }
}

enum FieldType {
  tomatoes,
  lettuce,
  corn,
  wheat,
  rice,
  other,
}

enum CropHealth {
  excellent,
  good,
  average,
  poor,
  bad,
  unknown,
}

class ProductivityZone {
  final String id;
  final ZoneProductivity level;
  final double yieldKgPerHa;
  final List<LatLng> boundaries;
  
  ProductivityZone({
    required this.id,
    required this.level,
    required this.yieldKgPerHa,
    required this.boundaries,
  });
  
  // For Firebase storage/retrieval
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'level': level.toString(),
      'yieldKgPerHa': yieldKgPerHa,
      'boundaries': boundaries.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude
      }).toList(),
    };
  }
  
  // Create a Zone from a map
  factory ProductivityZone.fromMap(Map<String, dynamic> map) {
    final level = ZoneProductivity.values.firstWhere(
      (e) => e.toString() == map['level'],
      orElse: () => ZoneProductivity.average,
    );
    
    return ProductivityZone(
      id: map['id'],
      level: level,
      yieldKgPerHa: map['yieldKgPerHa'],
      boundaries: List<Map<String, dynamic>>.from(map['boundaries'])
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
    );
  }
  
  // Get color based on productivity level
  Color get color {
    switch (level) {
      case ZoneProductivity.veryHigh:
        return Colors.green;
      case ZoneProductivity.high:
        return Colors.lightGreen;
      case ZoneProductivity.average:
        return Colors.yellow;
      case ZoneProductivity.low:
        return Colors.orange;
      case ZoneProductivity.veryLow:
        return Colors.red;
    }
  }
}

enum ZoneProductivity {
  veryHigh,
  high,
  average,
  low,
  veryLow,
}
