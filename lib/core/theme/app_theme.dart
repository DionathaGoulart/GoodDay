import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Spotify Dark Base ---
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF282828);
  static const Color onSurface = Colors.white;
  static const Color secondaryText = Color(0xFFB3B3B3);

  // --- Pastel Palette (Accents) ---
  static const Color pastelGreen = Color(0xFFB9FBC0);
  static const Color pastelTeal = Color(0xFF98F5E1);
  static const Color pastelYellow = Color(0xFFFBF8CC);
  static const Color pastelPink = Color(0xFFFFCFD2);
  static const Color pastelPurple = Color(0xFFF1C0E8);
  static const Color pastelBlue = Color(0xFFA2C3FC); // Pastel Blue
  static const Color pastelOrange = Color(0xFFFFD8B1); // Pastel Orange
  static const Color pastelIndigo = Color(0xFFC5A3FF); // Pastel Indigo
  static const Color pastelCyan = Color(0xFFB2F2F2); // Pastel Cyan
  
  static const List<Color> pastelColors = [
    pastelGreen, pastelTeal, pastelYellow, pastelPink, pastelPurple,
    pastelBlue, pastelOrange, pastelIndigo, pastelCyan,
  ];

  // Main Accent
  static const Color primaryColor = pastelGreen; 

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primaryColor,
        onPrimary: Colors.black, // Dark text on light pastel
        secondary: pastelTeal,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: onSurface,
        error: pastelPink,
        onError: Colors.black,
        background: background,
        onBackground: onSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Modern transparent look
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000), // Slightly darker than background for contrast
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: secondaryText),
        contentPadding: const EdgeInsets.all(16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(color: onSurface, fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: secondaryText, fontSize: 16),
      ),
      // Custom helpers
      extensions: const [
        // You could add custom colors here if needed
      ],
    );
  }
}
