import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors from Logo
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color secondaryGreen = Color(0xFF2D6A4F);
  static const Color accentGreen = Color(0xFF95D5B2);
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFF4E4C1);
  static const Color darkGreen = Color(0xFF081C15);
  static const Color turquoise = Color(0xFF17A2B8);
  
  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B4332);
  static const Color textSecondary = Color(0xFF52796F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryGold,
        tertiary: accentGreen,
        surface: cardBackground,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSecondary: primaryGreen,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: primaryGold,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryGold,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: primaryGold),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardBackground,
        shadowColor: primaryGreen.withOpacity(0.1),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: primaryGreen,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: backgroundLight,
        selectedColor: primaryGold.withOpacity(0.2),
        labelStyle: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: primaryGreen.withOpacity(0.2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: primaryGreen,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryGreen,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGreen.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryGold, width: 2),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: primaryGreen,
        elevation: 4,
      ),
    );
  }

  // Gradient Backgrounds
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );

  static LinearGradient get goldGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, lightGold],
  );

  // Box Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryGreen.withOpacity(0.08),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: primaryGold.withOpacity(0.3),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
