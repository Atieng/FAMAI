import 'package:flutter/material.dart';
import 'package:famai/models/planting_plan_model.dart';
import 'package:famai/services/calendar_service.dart';

class AddPlanScreen extends StatefulWidget {
  const AddPlanScreen({super.key});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  DateTime _plantingDate = DateTime.now();
  final _calendarService = CalendarService();
  bool _isLoading = false;

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  Future<void> _selectPlantingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _plantingDate) {
      setState(() {
        _plantingDate = picked;
      });
    }
  }

  Future<void> _addPlan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // For now, we'll use a fixed growing period of 90 days.
      final estimatedHarvestDate = _plantingDate.add(const Duration(days: 90));

      final newPlan = PlantingPlan(
        id: '', // Firestore will generate this
        cropId: _cropController.text,
        plantingDate: _plantingDate,
        estimatedHarvestDate: estimatedHarvestDate,
      );

      try {
        await _calendarService.addPlantingPlan(newPlan);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add plan: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _cropController,
                decoration: const InputDecoration(labelText: 'Crop Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a crop name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Planting Date: ${_plantingDate.toLocal().toString().split(' ')[0]}'),
                  ),
                  TextButton(
                    onPressed: () => _selectPlantingDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addPlan,
                      child: const Text('Add Plan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
