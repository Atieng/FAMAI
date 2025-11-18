import 'package:cloud_firestore/cloud_firestore.dart';

class PlantingPlan {
  final String id;
  final String cropId;
  final DateTime plantingDate;
  final DateTime estimatedHarvestDate;
  final List<String> imageUrls;
  final List<String> notes;
  final double expenses;

  PlantingPlan({
    required this.id,
    required this.cropId,
    required this.plantingDate,
    required this.estimatedHarvestDate,
    this.imageUrls = const [],
    this.notes = const [],
    this.expenses = 0.0,
  });

  factory PlantingPlan.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PlantingPlan(
      id: doc.id,
      cropId: data['cropId'] ?? '',
      plantingDate: (data['plantingDate'] as Timestamp).toDate(),
      estimatedHarvestDate: (data['estimatedHarvestDate'] as Timestamp).toDate(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      notes: List<String>.from(data['notes'] ?? []),
      expenses: (data['expenses'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cropId': cropId,
      'plantingDate': plantingDate,
      'estimatedHarvestDate': estimatedHarvestDate,
      'imageUrls': imageUrls,
      'notes': notes,
      'expenses': expenses,
    };
  }
}
