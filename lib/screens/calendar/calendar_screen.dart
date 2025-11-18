import 'package:flutter/material.dart';
import 'package:famai/models/planting_plan_model.dart';
import 'package:famai/services/calendar_service.dart';
import 'package:famai/screens/calendar/add_plan_screen.dart';
import 'package:famai/widgets/crop_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _calendarService = CalendarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Famcal')),
      body: StreamBuilder<List<PlantingPlan>>(
        stream: _calendarService.getPlantingPlans(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final plans = snapshot.data ?? [];

          if (plans.isEmpty) {
            return const Center(child: Text('No planting plans yet.'));
          }

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              return CropCard(plan: plans[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPlanScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
