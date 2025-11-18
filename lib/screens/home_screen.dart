import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:famai/screens/chat/conversations_screen.dart';
import 'package:famai/screens/map/map_screen.dart';
import 'package:famai/screens/calendar/calendar_screen.dart';
import 'package:famai/screens/scan/scan_screen.dart';
import 'package:famai/screens/community/community_screen.dart';
import 'package:famai/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ConversationsScreen(),
    const MapScreen(),
    const CalendarScreen(),
    const ScanScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bot),
            activeIcon: Icon(LucideIcons.bot, color: Theme.of(context).colorScheme.primary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.map),
            activeIcon: Icon(LucideIcons.map, color: Theme.of(context).colorScheme.primary),
            label: 'Famap',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar),
            activeIcon: Icon(LucideIcons.calendar, color: Theme.of(context).colorScheme.primary),
            label: 'Famcal',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.scanLine),
            activeIcon: Icon(LucideIcons.scanLine, color: Theme.of(context).colorScheme.primary),
            label: 'Fascan',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            activeIcon: Icon(LucideIcons.users, color: Theme.of(context).colorScheme.primary),
            label: 'FaCom',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            activeIcon: Icon(LucideIcons.user, color: Theme.of(context).colorScheme.primary),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
      ),
    );
  }
}
