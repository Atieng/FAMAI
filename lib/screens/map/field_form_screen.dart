import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:famai/models/field_data_model.dart';
import 'package:famai/services/field_service.dart';
import 'package:uuid/uuid.dart';

class FieldFormScreen extends StatefulWidget {
  final FarmField? field;
  
  const FieldFormScreen({
    super.key,
    this.field,
  });

  @override
  State<FieldFormScreen> createState() => _FieldFormScreenState();
}

class _FieldFormScreenState extends State<FieldFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fieldService = FieldService();
  final _uuid = const Uuid();
  
  late String _name;
  late double _areaHectares;
  late FieldType _fieldType;
  late List<LatLng> _boundaries;
  late double _waterLevel;
  late DateTime _plantingDate;
  late CropHealth _cropHealth;
  
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }
  
  void _initializeFormValues() {
    if (widget.field != null) {
      // Editing existing field
      _name = widget.field!.name;
      _areaHectares = widget.field!.areaHectares;
      _fieldType = widget.field!.type;
      _boundaries = List.from(widget.field!.boundaries);
      _waterLevel = widget.field!.waterLevel;
      _plantingDate = widget.field!.plantingDate;
      _cropHealth = widget.field!.cropHealth;
    } else {
      // Creating new field
      _name = '';
      _areaHectares = 0.0;
      _fieldType = FieldType.other;
      _boundaries = [
        const LatLng(-7.7956, 110.3695),
        const LatLng(-7.7956, 110.3705),
        const LatLng(-7.7966, 110.3705),
        const LatLng(-7.7966, 110.3695),
      ];
      _waterLevel = 80.0;
      _plantingDate = DateTime.now();
      _cropHealth = CropHealth.good;
    }
  }
  
  Future<void> _saveField() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        _isSaving = true;
      });
      
      try {
        final field = FarmField(
          id: widget.field?.id ?? _uuid.v4(),
          name: _name,
          areaHectares: _areaHectares,
          boundaries: _boundaries,
          type: _fieldType,
          productivityZones: widget.field?.productivityZones ?? [],
          waterLevel: _waterLevel,
          plantingDate: _plantingDate,
          cropHealth: _cropHealth,
        );
        
        await _fieldService.saveField(field);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving field: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field == null ? 'Add New Field' : 'Edit Field'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    initialValue: _name,
                    decoration: const InputDecoration(
                      labelText: 'Field Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your field';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Field Type Dropdown
                  DropdownButtonFormField<FieldType>(
                    value: _fieldType,
                    decoration: const InputDecoration(
                      labelText: 'Field Type',
                      border: OutlineInputBorder(),
                    ),
                    items: FieldType.values.map((type) {
                      return DropdownMenuItem<FieldType>(
                        value: type,
                        child: Text(type.toString().split('.').last.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _fieldType = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a field type';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _fieldType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Area
                  TextFormField(
                    initialValue: _areaHectares.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Area (hectares)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter field area';
                      }
                      final area = double.tryParse(value);
                      if (area == null || area <= 0) {
                        return 'Please enter a valid area';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _areaHectares = double.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Water Level Slider
                  const Text('Water Level', style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _waterLevel,
                    min: 0.0,
                    max: 100.0,
                    divisions: 10,
                    label: '${_waterLevel.round()}%',
                    onChanged: (value) {
                      setState(() {
                        _waterLevel = value;
                      });
                    },
                  ),
                  
                  // Date Picker
                  ListTile(
                    title: const Text('Planting Date'),
                    subtitle: Text(
                      '${_plantingDate.day}/${_plantingDate.month}/${_plantingDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _plantingDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _plantingDate = date;
                        });
                      }
                    },
                  ),
                  
                  // Crop Health Dropdown
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CropHealth>(
                    value: _cropHealth,
                    decoration: const InputDecoration(
                      labelText: 'Crop Health',
                      border: OutlineInputBorder(),
                    ),
                    items: CropHealth.values.map((health) {
                      return DropdownMenuItem<CropHealth>(
                        value: health,
                        child: Text(health.toString().split('.').last.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _cropHealth = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select crop health';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _cropHealth = value!;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveField,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.field == null ? 'Create Field' : 'Update Field',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
