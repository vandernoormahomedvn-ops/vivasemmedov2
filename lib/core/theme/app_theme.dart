import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF00B4D8); // Cyan/Light Blue
  static const Color secondaryColor = Color(0xFF03045E); // Deep Blue
  static const Color backgroundColor = Color(0xFFF8F9FA); // Very light gray
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212529);
  static const Color textSecondaryColor = Color(0xFF6C757D);
  static const Color errorColor = Color(0xFFD62828);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
            fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor),
        displayMedium: GoogleFonts.outfit(
            fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor),
        titleLarge: GoogleFonts.outfit(
            fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryColor),
        bodyLarge: GoogleFonts.inter(
            fontSize: 16, color: textPrimaryColor),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, color: textSecondaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: textSecondaryColor),
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
      ),
    );
  }
}
