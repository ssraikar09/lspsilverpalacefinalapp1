import 'package:flutter/material.dart';

class AppTheme {
  // Premium muted luxury dark palette
  static const Color darkBackground = Color(0xFF0F0F0F); // Deeper, more premium black
  static const Color primaryBurgundy = Color(0xFF6B1428); // Deep elegant burgundy
  static const Color silverText = Color(0xFFE8E8E8); // Soft silver
  static const Color goldAccent = Color(0xFFD4AF37); // Classic jewellery gold
  static const Color cardBackground = Color(0xFF161616); // Very subtle elevation
  static const Color surfaceColor = Color(0xFF161616);

  static ThemeData get darkLuxuryTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryBurgundy,
      colorScheme: const ColorScheme.dark(
        primary: primaryBurgundy,
        secondary: goldAccent,
        surface: surfaceColor,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Subtle rounded corners
        ),
        elevation: 0, // Flat premium look
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: silverText),
        titleTextStyle: TextStyle(
          color: silverText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0, // Luxury spacing
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: goldAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBurgundy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldAccent,
          side: const BorderSide(color: goldAccent),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1.0),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: silverText, fontSize: 32, fontWeight: FontWeight.w300, letterSpacing: 1.5),
        displayMedium: TextStyle(color: silverText, fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 1.2),
        titleLarge: TextStyle(color: silverText, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.1),
        titleMedium: TextStyle(color: silverText, fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: silverText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: Color(0xFF909090), fontSize: 12),
      ),
      useMaterial3: true,
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
        space: 24,
      ),
    );
  }
}
