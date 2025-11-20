import 'package:flutter/material.dart';
import 'package:famai/models/land_model.dart';
import 'package:famai/services/land_service.dart';
import 'package:famai/screens/map/add_land_screen.dart';
import 'package:famai/screens/map/land_detail_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Screen to display all user's land plots
class LandListScreen extends StatefulWidget {
  const LandListScreen({super.key});

  @override
  State<LandListScreen> createState() => _LandListScreenState();
}

class _LandListScreenState extends State<LandListScreen> {
  final LandService _landService = LandService();
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lands'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Land>>(
        stream: _landService.getLands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Once we have data, update loading state
          if (_isLoading && snapshot.connectionState != ConnectionState.waiting) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isLoading = false;
              });
            });
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text('Error loading lands: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final lands = snapshot.data ?? [];
          
          if (lands.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_land.png',
                    width: 150,
                    height: 150,
                    errorBuilder: (_, __, ___) => const Icon(
                      LucideIcons.map, 
                      size: 100,
                      color: Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Lands Added Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add your first land plot to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add Land'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _navigateToAddLand,
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isLoading = true;
              });
              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                _isLoading = false;
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lands.length,
              itemBuilder: (context, index) {
                final land = lands[index];
                return _buildLandCard(land);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddLand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLandCard(Land land) {
    // Calculate center of the land for the static map preview
    double latSum = 0, lngSum = 0;
    for (final point in land.coordinates) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    final centerLat = latSum / land.coordinates.length;
    final centerLng = lngSum / land.coordinates.length;
    
    // Placeholder for Google Static Maps API image
    final staticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$centerLat,$centerLng'
        '&zoom=15'
        '&size=400x200'
        '&maptype=satellite'
        '&key=AIzaSyBzQl6m4GtCUuHH2VDkmcXxXNtOXOx6uJk'; // Use your API key

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToLandDetails(land),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map preview image
            Stack(
              children: [
                Image.network(
                  staticMapUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(LucideIcons.map, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(land.areaSquareMeters / 10000).toStringAsFixed(2)} ha',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          land.nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (land.plantType != null && land.plantType!.isNotEmpty)
                        Chip(
                          label: Text(land.plantType!),
                          backgroundColor: Colors.green[100],
                          labelStyle: TextStyle(
                            color: Colors.green[800],
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.landscape, size: 16, color: Colors.brown[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Soil: ${land.analysis.soilSuitability.quality}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(LucideIcons.droplet, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${land.analysis.waterSource.type}: ${land.analysis.waterSource.name}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.thermometer, size: 16, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Temp: ${land.analysis.weather.temperature.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(LucideIcons.cloud, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Rainfall: ${land.analysis.weather.rainfall.toStringAsFixed(0)} mm',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToAddLand() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLandScreen(),
      ),
    );
    
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
    }
  }
  
  void _navigateToLandDetails(Land land) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandDetailScreen(landId: land.id),
      ),
    );
  }
}
