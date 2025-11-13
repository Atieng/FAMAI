import 'package:famai/screens/auth/profile_screen.dart';
import 'package:famai/screens/famai_chat/farmai_chat_screen.dart';
import 'package:famai/screens/famap/famap_screen.dart';
import 'package:famai/screens/fascan/fascan_screen.dart';
import 'package:famai/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FamaiChatScreen(),
    const FamapScreen(),
    const ProfileScreen(),
  ];

  void _navigateTo(int index) {
    if (index == 2) { // Special case for the scan button
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FascanScreen()));
    } else {
      setState(() {
        _pageIndex = index > 2 ? index - 1 : index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAMAI'),
        centerTitle: true,
      ),
      body: _pages[_pageIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateTo(2),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home_outlined, 'Home', 0),
            _buildNavItem(Icons.chat_bubble_outline, 'Chat', 1),
            const SizedBox(width: 48), // The space for the FAB
            _buildNavItem(Icons.map_outlined, 'Map', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index > 2 ? (_pageIndex == index - 1) : (_pageIndex == index);
    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
      onPressed: () => _navigateTo(index),
      tooltip: label,
    );
  }
}
