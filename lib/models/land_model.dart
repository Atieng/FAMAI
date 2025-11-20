import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model for land plots in the FamAi app
class Land {
  final String id;
  final String nickname;
  final List<LatLng> coordinates;
  final double areaSquareMeters;
  final LandAnalysis analysis;
  final String? plantType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Land({
    required this.id,
    required this.nickname,
    required this.coordinates,
    required this.areaSquareMeters,
    required this.analysis,
    this.plantType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to polygon for display on map
  Polygon toPolygon({
    Color? fillColor,
    Color? strokeColor,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Polygon(
      polygonId: PolygonId(id),
      points: coordinates,
      fillColor: selected 
        ? (fillColor ?? Colors.green.withOpacity(0.5)) 
        : (fillColor ?? Colors.green.withOpacity(0.3)),
      strokeColor: selected 
        ? (strokeColor ?? Colors.green) 
        : (strokeColor ?? Colors.green.withOpacity(0.7)),
      strokeWidth: selected ? 3 : 2,
      consumeTapEvents: onTap != null,
      onTap: onTap,
    );
  }

  // Create Land from Firestore document
  factory Land.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Land(
      id: doc.id,
      nickname: data['nickname'] ?? 'Unnamed Land',
      coordinates: (data['coordinates'] as List).map((point) {
        return LatLng((point['latitude'] as num).toDouble(), 
                     (point['longitude'] as num).toDouble());
      }).toList(),
      areaSquareMeters: (data['area'] as num).toDouble(),
      analysis: LandAnalysis.fromMap(data['analysis'] as Map<String, dynamic>),
      plantType: data['plant_type'],
      notes: data['notes'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Convert Land to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'coordinates': coordinates.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'area': areaSquareMeters,
      'analysis': analysis.toMap(),
      'plant_type': plantType,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Create a copy with modifications
  Land copyWith({
    String? nickname,
    List<LatLng>? coordinates,
    double? areaSquareMeters,
    LandAnalysis? analysis,
    String? plantType,
    String? notes,
    DateTime? updatedAt,
  }) {
    return Land(
      id: id,
      nickname: nickname ?? this.nickname,
      coordinates: coordinates ?? this.coordinates,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      analysis: analysis ?? this.analysis,
      plantType: plantType ?? this.plantType,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// Model for land analysis data
class LandAnalysis {
  final Weather weather;
  final WaterSource waterSource;
  final AirCondition airCondition;
  final SoilSuitability soilSuitability;
  final List<String> recommendedCrops;

  LandAnalysis({
    required this.weather,
    required this.waterSource,
    required this.airCondition,
    required this.soilSuitability,
    required this.recommendedCrops,
  });

  // Create default analysis
  factory LandAnalysis.defaultAnalysis() {
    return LandAnalysis(
      weather: Weather.defaultWeather(),
      waterSource: WaterSource.defaultWaterSource(),
      airCondition: AirCondition.defaultAirCondition(),
      soilSuitability: SoilSuitability.defaultSoilSuitability(),
      recommendedCrops: ['Data not available'],
    );
  }

  // Create analysis from Firestore map
  factory LandAnalysis.fromMap(Map<String, dynamic> map) {
    return LandAnalysis(
      weather: Weather.fromMap(map['weather'] as Map<String, dynamic>),
      waterSource: WaterSource.fromMap(map['water_source'] as Map<String, dynamic>),
      airCondition: AirCondition.fromMap(map['air_condition'] as Map<String, dynamic>),
      soilSuitability: SoilSuitability.fromMap(map['soil_suitability'] as Map<String, dynamic>),
      recommendedCrops: List<String>.from(map['recommended_crops']),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'weather': weather.toMap(),
      'water_source': waterSource.toMap(),
      'air_condition': airCondition.toMap(),
      'soil_suitability': soilSuitability.toMap(),
      'recommended_crops': recommendedCrops,
    };
  }
}

/// Model for weather data
class Weather {
  final double temperature;
  final double rainfall;
  final double humidity;
  final String summary;
  final String monthlyBreakdown;

  Weather({
    required this.temperature,
    required this.rainfall,
    required this.humidity,
    required this.summary,
    required this.monthlyBreakdown,
  });

  factory Weather.defaultWeather() {
    return Weather(
      temperature: 0.0,
      rainfall: 0.0,
      humidity: 0.0,
      summary: 'Data not available',
      monthlyBreakdown: 'Data not available',
    );
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      temperature: (map['temperature'] as num).toDouble(),
      rainfall: (map['rainfall'] as num).toDouble(),
      humidity: (map['humidity'] as num).toDouble(),
      summary: map['summary'] as String,
      monthlyBreakdown: map['monthly_breakdown'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'rainfall': rainfall,
      'humidity': humidity,
      'summary': summary,
      'monthly_breakdown': monthlyBreakdown,
    };
  }
}

/// Model for water source data
class WaterSource {
  final String name;
  final double distance;
  final String type;
  final double reliability;

  WaterSource({
    required this.name,
    required this.distance,
    required this.type,
    required this.reliability,
  });

  factory WaterSource.defaultWaterSource() {
    return WaterSource(
      name: 'Unknown',
      distance: 0.0,
      type: 'Unknown',
      reliability: 0.0,
    );
  }

  factory WaterSource.fromMap(Map<String, dynamic> map) {
    return WaterSource(
      name: map['name'] as String,
      distance: (map['distance'] as num).toDouble(),
      type: map['type'] as String,
      reliability: (map['reliability'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distance': distance,
      'type': type,
      'reliability': reliability,
    };
  }
}

/// Model for air condition data
class AirCondition {
  final double quality;
  final String description;
  final Map<String, double> pollutants;

  AirCondition({
    required this.quality,
    required this.description,
    required this.pollutants,
  });

  factory AirCondition.defaultAirCondition() {
    return AirCondition(
      quality: 0.0,
      description: 'Data not available',
      pollutants: {},
    );
  }

  factory AirCondition.fromMap(Map<String, dynamic> map) {
    return AirCondition(
      quality: (map['quality'] as num).toDouble(),
      description: map['description'] as String,
      pollutants: Map<String, double>.from(map['pollutants']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quality': quality,
      'description': description,
      'pollutants': pollutants,
    };
  }
}

/// Model for soil suitability data
class SoilSuitability {
  final String quality;
  final Map<String, double> nutrients;
  final double ph;
  final String texture;

  SoilSuitability({
    required this.quality,
    required this.nutrients,
    required this.ph,
    required this.texture,
  });

  factory SoilSuitability.defaultSoilSuitability() {
    return SoilSuitability(
      quality: 'Unknown',
      nutrients: {},
      ph: 0.0,
      texture: 'Unknown',
    );
  }

  factory SoilSuitability.fromMap(Map<String, dynamic> map) {
    return SoilSuitability(
      quality: map['quality'] as String,
      nutrients: Map<String, double>.from(map['nutrients']),
      ph: (map['ph'] as num).toDouble(),
      texture: map['texture'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quality': quality,
      'nutrients': nutrients,
      'ph': ph,
      'texture': texture,
    };
  }
}
