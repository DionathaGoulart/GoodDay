import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores principais
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF2ECC71);
  static const Color errorColor = Color(0xFFE74C3C);

  // --- Normal Mode (Dark Purple/WhatsApp-like) ---
  static const Color normalPrimary = Color(0xFF6C63FF); // Deep Purple
  static const Color normalSecondary = Color(0xFF075E54); // WhatsApp Teal-ish accent
  static const Color normalBackground = Color(0xFF121212); // standard dark bg
  static const Color normalSurface = Color(0xFF1E1E1E); // slightly lighter for cards

  static ThemeData normalTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: normalBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: normalPrimary,
      primary: normalPrimary,
      secondary: normalSecondary,
      surface: normalSurface,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: normalSurface, 
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: normalSurface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: normalPrimary,
      foregroundColor: Colors.white,
    ),
  );

  // --- Minimalist Mode (Dark Manga/Horror - White on Black) ---
  static ThemeData minimalistTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.crimsonTextTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Crimson Text'),
      iconTheme: IconThemeData(color: Colors.white),
      shape: Border(bottom: BorderSide(color: Colors.white, width: 2)), // White border
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: Colors.white, width: 2), // White border
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 2)),
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(color: Colors.white, thickness: 1),
    checkboxTheme: CheckboxThemeData(
      checkColor: const MaterialStatePropertyAll(Colors.black),
      fillColor: const MaterialStatePropertyAll(Colors.white),
      side: const BorderSide(color: Colors.white, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.black),
  );
}
