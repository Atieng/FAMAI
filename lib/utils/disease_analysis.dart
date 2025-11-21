import '../models/plant_disease_model.dart';

class DiseaseAnalysis {
  final PlantDiseaseResult diseaseResult;
  final List<String> recommendations;
  final List<String> urgentActions;
  final List<String> preventiveMeasures;
  final String riskAssessment;
  final String nextSteps;

  DiseaseAnalysis({
    required this.diseaseResult,
    required this.recommendations,
    required this.urgentActions,
    required this.preventiveMeasures,
    required this.riskAssessment,
    required this.nextSteps,
  });

  factory DiseaseAnalysis.fromDiseaseResult(PlantDiseaseResult result) {
    final recommendations = _generateRecommendations(result);
    final urgentActions = _generateUrgentActions(result);
    final preventiveMeasures = _generatePreventiveMeasures(result);
    final riskAssessment = _generateRiskAssessment(result);
    final nextSteps = _generateNextSteps(result);

    return DiseaseAnalysis(
      diseaseResult: result,
      recommendations: recommendations,
      urgentActions: urgentActions,
      preventiveMeasures: preventiveMeasures,
      riskAssessment: riskAssessment,
      nextSteps: nextSteps,
    );
  }

  static List<String> _generateRecommendations(PlantDiseaseResult result) {
    final List<String> recommendations = [];
    
    // Add treatment-based recommendations
    if (result.treatment != 'N/A' && result.treatment.isNotEmpty) {
      recommendations.add('Treatment: ${result.treatment}');
    }
    
    // Add confidence-based recommendations
    if (result.confidenceValue >= 80) {
      recommendations.add('High confidence detection - immediate action recommended');
      recommendations.add('Consider isolating affected plants to prevent spread');
    } else if (result.confidenceValue >= 60) {
      recommendations.add('Moderate confidence - monitor closely and consider treatment');
    } else {
      recommendations.add('Lower confidence - seek professional confirmation');
      recommendations.add('Monitor plant condition daily for changes');
    }

    // Add plant-specific recommendations
    final plant = result.plantType.toLowerCase();
    if (plant.contains('tomato')) {
      recommendations.add('Check humidity levels and ensure proper ventilation');
    } else if (plant.contains('apple')) {
      recommendations.add('Inspect nearby trees for similar symptoms');
      recommendations.add('Consider pruning affected branches');
    } else if (plant.contains('corn')) {
      recommendations.add('Check soil moisture and drainage');
      recommendations.add('Monitor crop density for air circulation');
    }

    return recommendations;
  }

  static List<String> _generateUrgentActions(PlantDiseaseResult result) {
    final List<String> urgent = [];
    
    if (result.confidenceValue >= 80) {
      urgent.add('🚨 Immediate treatment required');
      urgent.add('🚨 Remove and destroy severely infected parts');
      urgent.add('🚨 Apply appropriate fungicide/pesticide');
    }
    
    if (result.label.toLowerCase().contains('blight') || 
        result.label.toLowerCase().contains('rot')) {
      urgent.add('⚠️ High risk of spread - act quickly');
      urgent.add('⚠️ Separate from healthy plants immediately');
    }

    return urgent;
  }

  static List<String> _generatePreventiveMeasures(PlantDiseaseResult result) {
    final List<String> preventive = [];
    
    if (result.prevention != 'N/A' && result.prevention.isNotEmpty) {
      preventive.add('Prevention: ${result.prevention}');
    }
    
    // General preventive measures
    preventive.addAll([
      'Ensure proper plant spacing for air circulation',
      'Avoid overhead watering to reduce leaf moisture',
      'Regularly inspect plants for early symptoms',
      'Maintain proper soil drainage',
      'Use disease-resistant varieties when possible',
      'Clean tools between plants to prevent spread',
      'Remove plant debris from growing area',
    ]);

    return preventive;
  }

  static String _generateRiskAssessment(PlantDiseaseResult result) {
    final confidence = result.confidenceValue;
    final diseaseName = result.diseaseName.toLowerCase();
    
    if (confidence >= 80) {
      if (diseaseName.contains('blight') || diseaseName.contains('rot')) {
        return '🔴 HIGH RISK - Aggressive disease with high confidence detection';
      } else {
        return '🟠 MEDIUM-HIGH RISK - Confirmed disease requires immediate attention';
      }
    } else if (confidence >= 60) {
      return '🟡 MEDIUM RISK - Likely disease, close monitoring needed';
    } else {
      return '🟢 LOW-MEDIUM RISK - Possible disease, seek confirmation';
    }
  }

  static String _generateNextSteps(PlantDiseaseResult result) {
    final steps = StringBuffer();
    
    steps.writeln('1. Document the symptoms with photos for reference');
    steps.writeln('2. Isolate affected plants if possible');
    
    if (result.confidenceValue >= 70) {
      steps.writeln('3. Apply recommended treatment immediately');
      steps.writeln('4. Monitor response to treatment over 3-7 days');
    } else {
      steps.writeln('3. Consult with local agricultural extension');
      steps.writeln('4. Consider laboratory testing for confirmation');
    }
    
    steps.writeln('5. Implement preventive measures for surrounding plants');
    steps.writeln('6. Schedule regular monitoring for early detection');
    
    return steps.toString();
  }

  // Get summary for quick display
  String get summary {
    return '${diseaseResult.diseaseName} detected with ${diseaseResult.confidence} confidence. ${diseaseResult.severity.displayName} severity.';
  }

  // Get action priority
  ActionPriority get actionPriority {
    if (diseaseResult.confidenceValue >= 80) {
      return ActionPriority.immediate;
    } else if (diseaseResult.confidenceValue >= 60) {
      return ActionPriority.soon;
    } else {
      return ActionPriority.monitor;
    }
  }
}

enum ActionPriority {
  immediate,
  soon,
  monitor;

  String get displayName {
    switch (this) {
      case ActionPriority.immediate:
        return 'Act Immediately';
      case ActionPriority.soon:
        return 'Act Soon';
      case ActionPriority.monitor:
        return 'Monitor Closely';
    }
  }

  String get color {
    switch (this) {
      case ActionPriority.immediate:
        return '#F44336'; // Red
      case ActionPriority.soon:
        return '#FF9800'; // Orange
      case ActionPriority.monitor:
        return '#2196F3'; // Blue
    }
  }
}
