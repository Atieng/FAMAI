class PlantDiseaseResult {
  final String label;
  final String confidence;
  final String description;
  final String cause;
  final String treatment;
  final String prevention;

  PlantDiseaseResult({
    required this.label,
    required this.confidence,
    required this.description,
    required this.cause,
    required this.treatment,
    required this.prevention,
  });

  factory PlantDiseaseResult.fromJson(Map<String, dynamic> json) {
    return PlantDiseaseResult(
      label: json['label'] ?? 'Unknown Disease',
      confidence: json['confidence'] ?? '0%',
      description: json['description'] ?? 'No description available.',
      cause: json['cause'] ?? 'N/A',
      treatment: json['treatment'] ?? 'N/A',
      prevention: json['prevention'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'description': description,
      'cause': cause,
      'treatment': treatment,
      'prevention': prevention,
    };
  }

  // Get disease name without plant type
  String get diseaseName {
    final parts = label.split(' - ');
    return parts.length > 1 ? parts[1] : label;
  }

  // Get plant type
  String get plantType {
    final parts = label.split(' - ');
    return parts[0];
  }

  // Get confidence as double
  double get confidenceValue {
    final confStr = confidence.replaceAll('%', '');
    return double.tryParse(confStr) ?? 0.0;
  }

  // Get severity based on confidence
  DiseaseSeverity get severity {
    final conf = confidenceValue;
    if (conf >= 80) return DiseaseSeverity.high;
    if (conf >= 60) return DiseaseSeverity.medium;
    return DiseaseSeverity.low;
  }

  @override
  String toString() {
    return 'PlantDiseaseResult(label: $label, confidence: $confidence)';
  }
}

enum DiseaseSeverity {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case DiseaseSeverity.low:
        return 'Low';
      case DiseaseSeverity.medium:
        return 'Medium';
      case DiseaseSeverity.high:
        return 'High';
    }
  }

  String get color {
    switch (this) {
      case DiseaseSeverity.low:
        return '#FFA726'; // Orange
      case DiseaseSeverity.medium:
        return '#FF7043'; // Deep Orange
      case DiseaseSeverity.high:
        return '#F44336'; // Red
    }
  }
}

class PlantDiseaseResponse {
  final List<PlantDiseaseResult> results;
  final String? error;

  PlantDiseaseResponse({
    required this.results,
    this.error,
  });

  factory PlantDiseaseResponse.fromJson(Map<String, dynamic> json) {
    if (json['error'] != null) {
      return PlantDiseaseResponse(
        results: [],
        error: json['error'],
      );
    }

    final resultsList = json['results'] as List<dynamic>? ?? [];
    final results = resultsList
        .map((result) => PlantDiseaseResult.fromJson(result))
        .toList();

    return PlantDiseaseResponse(results: results);
  }

  bool get hasError => error != null;
  bool get hasResults => results.isNotEmpty;
  PlantDiseaseResult? get primaryResult => hasResults ? results.first : null;
}
