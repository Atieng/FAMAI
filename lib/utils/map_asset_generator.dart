import 'package:famai/models/land_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility to generate sample map assets for the farm map feature
class MapAssetGenerator {
  /// Generate sample land plots for demonstration
  static List<Land> generateSampleLands() {
    return [
      _buildTomatoesField(),
      _buildCornField(),
      _buildLettuceField(),
    ];
  }
  
  /// Generate a sample tomatoes field
  static Land _buildTomatoesField() {
    return Land(
      id: 'tomatoes-field-1',
      nickname: 'Tomatoes Field',
      areaSquareMeters: 12000, // 1.2 hectares
      coordinates: const [
        LatLng(-7.7946, 110.3685),
        LatLng(-7.7946, 110.3705),
        LatLng(-7.7966, 110.3705),
        LatLng(-7.7966, 110.3685),
      ],
      analysis: LandAnalysis(
        weather: Weather(
          temperature: 24.5,
          rainfall: 900,
          humidity: 75.0,
          summary: 'Moderate rainfall with warm temperatures',
          monthlyBreakdown: 'Jan: Dry, Feb-Apr: Rainy, May-Aug: Dry, Sep-Dec: Moderate rainfall',
        ),
        waterSource: WaterSource(
          name: 'River Alpha',
          distance: 350,
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
          'Tomatoes',
          'Peppers',
          'Eggplant',
          'Onions',
          'Beans',
        ],
      ),
      plantType: 'Tomatoes',
      notes: 'Good irrigation source nearby. Need to apply compost in next season.',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    );
  }
  
  /// Generate a sample corn field
  static Land _buildCornField() {
    return Land(
      id: 'corn-field-1',
      nickname: 'Corn Field',
      areaSquareMeters: 8000, // 0.8 hectares
      coordinates: const [
        LatLng(-7.7976, 110.3685),
        LatLng(-7.7976, 110.3700),
        LatLng(-7.7986, 110.3700),
        LatLng(-7.7986, 110.3685),
      ],
      analysis: LandAnalysis(
        weather: Weather(
          temperature: 26.0,
          rainfall: 850,
          humidity: 68.0,
          summary: 'Sunny with moderate rainfall, ideal for corn growth',
          monthlyBreakdown: 'Jan-Mar: Dry, Apr-Sep: Rainy, Oct-Dec: Moderate rainfall',
        ),
        waterSource: WaterSource(
          name: 'Lake Beta',
          distance: 550,
          type: 'Lake',
          reliability: 90.0,
        ),
        airCondition: AirCondition(
          quality: 92.0,
          description: 'Excellent air quality year-round',
          pollutants: {
            'PM2.5': 8.1,
            'PM10': 15.3,
            'NO2': 6.2,
            'O3': 25.8,
          },
        ),
        soilSuitability: SoilSuitability(
          quality: 'Excellent',
          nutrients: {
            'Nitrogen': 78.4,
            'Phosphorus': 65.2,
            'Potassium': 80.3,
            'Organic Matter': 5.2,
          },
          ph: 6.8,
          texture: 'Loam',
        ),
        recommendedCrops: [
          'Corn',
          'Wheat',
          'Soybeans',
          'Sunflowers',
          'Millet',
        ],
      ),
      plantType: 'Corn',
      notes: 'Harvested good yield last season. Considering crop rotation next year.',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    );
  }
  
  /// Generate a sample lettuce field
  static Land _buildLettuceField() {
    return Land(
      id: 'lettuce-field-1',
      nickname: 'Lettuce Field',
      areaSquareMeters: 5000, // 0.5 hectares
      coordinates: const [
        LatLng(-7.7946, 110.3665),
        LatLng(-7.7946, 110.3675),
        LatLng(-7.7956, 110.3675),
        LatLng(-7.7956, 110.3665),
      ],
      analysis: LandAnalysis(
        weather: Weather(
          temperature: 22.0,
          rainfall: 650,
          humidity: 80.0,
          summary: 'Cool temperatures with consistent moisture',
          monthlyBreakdown: 'Year-round consistent rainfall pattern',
        ),
        waterSource: WaterSource(
          name: 'Stream Delta',
          distance: 150,
          type: 'Stream',
          reliability: 75.0,
        ),
        airCondition: AirCondition(
          quality: 85.0,
          description: 'Good air quality with morning fog',
          pollutants: {
            'PM2.5': 10.5,
            'PM10': 20.1,
            'NO2': 7.8,
            'O3': 28.5,
          },
        ),
        soilSuitability: SoilSuitability(
          quality: 'Very Good',
          nutrients: {
            'Nitrogen': 70.1,
            'Phosphorus': 60.8,
            'Potassium': 65.7,
            'Organic Matter': 4.5,
          },
          ph: 6.2,
          texture: 'Sandy Loam',
        ),
        recommendedCrops: [
          'Lettuce',
          'Spinach',
          'Kale',
          'Arugula',
          'Cabbage',
        ],
      ),
      plantType: 'Lettuce',
      notes: 'Perfect for leafy greens. Considering greenhouse installation for year-round production.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }
}
