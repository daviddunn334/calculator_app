import 'package:flutter/material.dart';

class AppTheme {
  // NEW DARK COLOR SYSTEM - Primary Foundation
  static const Color background = Color(0xFF1E232A); // Main Background
  static const Color surfaceElevated = Color(0xFF242A33); // Slightly Elevated Surface
  static const Color surface = Color(0xFF2A313B); // Card / Panel Surface

  // Text Colors
  static const Color textPrimary = Color(0xFFEDF9FF); // Primary Text
  static const Color textSecondary = Color(0xFFAEBBC8); // Secondary Text
  static const Color textMuted = Color(0xFF7F8A96); // Muted Text

  // Accent Colors
  static const Color primaryAccent = Color(0xFF6C5BFF); // Primary Accent (Main Action / Active State)
  static const Color secondaryAccent = Color(0xFF00E5A8); // Secondary Accent (Success / Confirmation / Highlights)
  static const Color accessoryAccent = Color(0xFFFE637E); // Accessory Accent (Alerts / Emphasis / Special Highlights)
  static const Color yellowAccent = Color(0xFFF8B800); // Yellow accent for highlights

  // Legacy color references maintained for compatibility
  static const Color primaryNavy = primaryAccent;
  static const Color accentGold = yellowAccent;
  static const Color primaryBlue = primaryAccent;
  static const Color accent1 = secondaryAccent;
  static const Color accent2 = Color(0xFF2A9D8F);
  static const Color accent3 = accessoryAccent;
  static const Color accent4 = Color(0xFFF72585);
  static const Color accent5 = Color(0xFF032B43);

  static const Color backgroundAlternative = Color(0xFFFEF9EF);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Theme Data - Dark Professional Theme
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Noto Sans, Noto Sans Symbols',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryAccent,
      secondary: secondaryAccent,
      tertiary: accessoryAccent,
      background: background,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      toolbarHeight: 56,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryAccent, width: 1),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingLarge,
        vertical: paddingMedium,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryAccent,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryAccent,
        side: const BorderSide(color: primaryAccent, width: 1),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Gradients - Limited use for buttons/small highlights only
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryAccent, Color(0xFF5a4fcf)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [yellowAccent, Color(0xFFe6a800)],
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
} 