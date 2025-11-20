import 'package:flutter/material.dart';
import 'package:famai/models/land_model.dart';
import 'package:famai/services/land_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Screen for user to input land details like nickname, notes, and crop type
class LandDetailsFormScreen extends StatefulWidget {
  final Land land;
  
  const LandDetailsFormScreen({
    super.key,
    required this.land,
  });

  @override
  State<LandDetailsFormScreen> createState() => _LandDetailsFormScreenState();
}

class _LandDetailsFormScreenState extends State<LandDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _notesController = TextEditingController();
  
  final LandService _landService = LandService();
  
  List<String> _availablePlantTypes = [];
  String? _selectedPlantType;
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _initializeFormValues();
    _loadPlantTypes();
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _initializeFormValues() {
    _nicknameController.text = widget.land.nickname;
    _notesController.text = widget.land.notes ?? '';
    _selectedPlantType = widget.land.plantType;
  }
  
  Future<void> _loadPlantTypes() async {
    try {
      final plantTypes = await _landService.getPlantTypes();
      if (mounted) {
        setState(() {
          _availablePlantTypes = plantTypes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plant types: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _availablePlantTypes = [];
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _saveLandDetails() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      final updatedLand = widget.land.copyWith(
        nickname: _nicknameController.text.trim(),
        notes: _notesController.text.trim(),
        plantType: _selectedPlantType,
        updatedAt: DateTime.now(),
      );
      
      await _landService.saveLand(updatedLand);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Land saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, true); // Return to analysis screen with success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save land: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSaving
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 24),
                      Text(
                        'Saving Land Details...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Land size info card
                        Card(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.map, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Land Size: ${(widget.land.areaSquareMeters / 10000).toStringAsFixed(2)} hectares',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Analyzed on ${widget.land.updatedAt.toString().substring(0, 10)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Nickname field
                        const Text(
                          'Land Nickname',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a name for your land',
                            prefixIcon: Icon(LucideIcons.tag),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name for your land';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Plant type dropdown
                        const Text(
                          'Select Main Crop',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedPlantType,
                          decoration: const InputDecoration(
                            hintText: 'Select a crop type',
                            prefixIcon: Icon(LucideIcons.leaf),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            ..._availablePlantTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            )).toList(),
                            const DropdownMenuItem(
                              value: '',
                              child: Text('-- None --'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPlantType = (value == '') ? null : value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Notes field
                        const Text(
                          'Notes (Optional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Add any additional notes about this land...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Connect with FamCal
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar, color: Colors.green[700]),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Connect with FamCal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Land will be available in FamCal for planning planting schedules',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveLandDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Save Land',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
