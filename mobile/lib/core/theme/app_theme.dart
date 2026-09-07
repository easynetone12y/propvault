import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary     = Color(0xFF185FA5);
  static const Color primaryDark = Color(0xFF0C447C);
  static const Color accent      = Color(0xFF25D366);
  static const Color success     = Color(0xFF3B6D11);
  static const Color warning     = Color(0xFFBA7517);
  static const Color danger      = Color(0xFFA32D2D);
  static const Color surface     = Color(0xFFF7F8FA);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, foregroundColor: Color(0xFF1A1A1A),
      elevation: 0, centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A), fontFamily: 'Inter'),
    ),
    scaffoldBackgroundColor: surface,
    cardTheme: CardThemeData(
      color: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border:        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
  );
}
