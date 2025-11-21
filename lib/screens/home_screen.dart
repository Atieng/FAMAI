import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:famai/screens/ai/ai_assistant_screen.dart';
import 'package:famai/screens/map/map_screen.dart'; // Using new MapScreen implementation
import 'package:famai/screens/calendar/calendar_screen.dart';
import 'package:famai/screens/climate/climate_screen.dart'; // Weather screen
import 'package:famai/screens/community/community_screen.dart';
import 'package:famai/screens/profile/profile_screen.dart';
import 'package:famai/widgets/modern_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const AIAssistantScreen(),      // AI Assistant (new implementation)
    const CommunityScreen(),        // FamCom 
    const MapScreen(),              // Famap (center highlighted button) - Using new implementation
    const ClimateScreen(),          // Weather screen (formerly Notifications)
    const CalendarScreen(),         // Calendar
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'AI Assistant';
      case 1:
        return 'FamCom';
      case 2:
        return 'FamMap';
      case 3:
        return 'Weather';
      case 4:
        return 'FamCal';
      default:
        return 'FamAi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Add profile icon to AppBar
          IconButton(
            icon: const Icon(LucideIcons.user),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen())
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: ModernBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
