import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define the core colors from the design
  static const Color _primaryGreen = Color(0xFF2C6B4A); // Dark green for buttons, icons, and highlights
  static const Color _backgroundGreen = Color(0xFFE8F5E9); // Very light green for backgrounds
  static const Color _darkTextColor = Color(0xFF1B3A2A); // Dark, almost black-green for text

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _primaryGreen,
      scaffoldBackgroundColor: _backgroundGreen,
      colorScheme: const ColorScheme.light(
        primary: _primaryGreen,
        secondary: _primaryGreen, // Can be a different accent color if needed
        background: _backgroundGreen,
        onBackground: _darkTextColor,
        surface: Colors.white, // For cards, dialogs
        onSurface: _darkTextColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundGreen, // Light background for AppBar
        foregroundColor: _darkTextColor, // Dark text/icons for AppBar
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: _darkTextColor),
        titleTextStyle: TextStyle(color: _darkTextColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Colors.white,
        elevation: 2,
      ),
      textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: _darkTextColor, displayColor: _darkTextColor),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    // TODO: Define a proper dark theme based on the design if one is provided
    return ThemeData(
      primarySwatch: Colors.green,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
    );
  }
}

