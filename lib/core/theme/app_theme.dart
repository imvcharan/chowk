import 'package:flutter/material.dart';

class AppTheme {
  // CHOWK Brand Colors
  static const Color kagazWhite = Color(0xFFFFFBF0); // background
  static const Color chowkBlack = Color(0xFF333333); // primary text/header
  static const Color chowkOrange = Color(0xFFFF6A00); // accent / button / live dot
  static const Color secondaryBorder = Color(0xFFE5E5E5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF6B7280);
  // Backwards-compatible aliases (used across the codebase)
  static const Color primaryRed = chowkOrange;
  static const Color darkRed = chowkOrange;
  static const Color lightRed = Color(0xFFFFF3EF);
  static const Color softWhite = kagazWhite;
  static const Color darkBase = chowkBlack;
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color mediumGray = secondaryBorder;
  static const Color lightText = Color(0xFF9CA3AF);
  static const Color accentOrange = chowkOrange;
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color white70 = Color(0xB3FFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kagazWhite,
      appBarTheme: const AppBarTheme(
        backgroundColor: kagazWhite,
        foregroundColor: chowkBlack,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      // Color scheme using CHOWK orange as accent
      colorScheme: ColorScheme.fromSeed(
        seedColor: chowkOrange,
        brightness: Brightness.light,
      ).copyWith(
        primary: chowkOrange,
        onPrimary: white,
        secondary: chowkOrange,
        surface: white,
        background: kagazWhite,
        onBackground: chowkBlack,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: chowkBlack,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: chowkBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: chowkBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: chowkBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: chowkBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: chowkBlack,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: mutedText,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mutedText,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: chowkBlack,
          letterSpacing: 0.5,
        ),
      ),
      cardColor: white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: chowkOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.chowkOrange),
        ),
        labelStyle: const TextStyle(color: mutedText, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: lightText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: chowkOrange,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: chowkOrange,
          side: const BorderSide(color: chowkOrange, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// Convenient shadow for premium feel
class AppShadows {
  static const BoxShadow small = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x2F000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> smallList = [small];
  static const List<BoxShadow> mediumList = [medium];
  static const List<BoxShadow> largeList = [large];
}
