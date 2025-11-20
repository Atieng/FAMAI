import 'package:flutter/material.dart';
import 'package:famai/screens/map/land_list_screen.dart';

/// Map Screen showing land plots and farm details
/// This is the main container for the Farm Map feature
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandListScreen();
  }
}
