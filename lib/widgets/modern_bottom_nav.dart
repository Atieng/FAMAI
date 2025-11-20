import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ModernBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = 24.0;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF00403C), // Dark green color like in the image
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // AI Button (first position)
          _buildNavItem(context, LucideIcons.bot, 'AI', 0, iconSize),
          
          // FamCom Button (now in second position)
          _buildNavItem(context, LucideIcons.users, 'FamCom', 1, iconSize),
          
          // Famap Button (Featured in center with highlight)
          _buildCenterNavItem(context, LucideIcons.mapPin, 'Famap', 2, iconSize, screenWidth),
          
          // Weather Button
          _buildNavItem(context, LucideIcons.cloud, 'Weather', 3, iconSize),
          
          // Calendar Button 
          _buildNavItem(context, LucideIcons.calendar, 'Famcal', 4, iconSize),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData iconData, String label, int index, double iconSize) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            size: iconSize,
          ),
          const SizedBox(height: 4),
          isSelected 
              ? Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(BuildContext context, IconData iconData, String label, int index, double iconSize, double screenWidth) {
    final isSelected = selectedIndex == index;
    
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF338984), // Lighter green for the center button
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF338984).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ] : [],
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
