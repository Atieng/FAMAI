import 'package:flutter/material.dart';
import 'package:famai/models/planting_plan_model.dart';

class CropCard extends StatelessWidget {
  final PlantingPlan plan;

  const CropCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.cropId, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Planted on: ${plan.plantingDate.toLocal().toString().split(' ')[0]}'),
            Text('Estimated Harvest: ${plan.estimatedHarvestDate.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _calculateProgress(),
              backgroundColor: Colors.brown[100],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    final now = DateTime.now();
    final totalDuration = plan.estimatedHarvestDate.difference(plan.plantingDate).inDays;
    final elapsedDuration = now.difference(plan.plantingDate).inDays;

    if (totalDuration == 0) return 1.0;
    double progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }
}
