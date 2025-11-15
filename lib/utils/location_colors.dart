import 'package:flutter/material.dart';

class LocationColors {
  // Available colors for folders and locations
  static const Map<String, Color> availableColors = {
    '3366FF': Color(0xFF3366FF), // Primary Blue
    'FFB703': Color(0xFFFFB703), // Yellow
    '8384EF': Color(0xFF8384EF), // Purple
    'FE644A': Color(0xFFFE644A), // Red/Orange
    '10B8FB': Color(0xFF10B8FB), // Light Blue
    '88961B': Color(0xFF88961B), // Olive/Green
    '0D99FA': Color(0xFF0D99FA), // Bright Blue
  };

  // Get Color from hex string
  static Color getColor(String hexString) {
    final color = availableColors[hexString.toUpperCase()];
    if (color != null) return color;
    
    // Fallback: try to parse any hex string
    try {
      return Color(int.parse('0xFF${hexString.replaceAll('#', '')}'));
    } catch (e) {
      return availableColors['3366FF']!; // Default to primary blue
    }
  }

  // Get color with opacity
  static Color getColorWithOpacity(String hexString, double opacity) {
    return getColor(hexString).withOpacity(opacity);
  }

  // Get a lighter version of the color (for backgrounds)
  static Color getLightColor(String hexString) {
    final baseColor = getColor(hexString);
    return HSLColor.fromColor(baseColor)
        .withLightness(0.9)
        .withSaturation(0.3)
        .toColor();
  }

  // Get all available color options for UI selection
  static List<MapEntry<String, Color>> getColorOptions() {
    return availableColors.entries.toList();
  }

  // Get color name for display
  static String getColorName(String hexString) {
    switch (hexString.toUpperCase()) {
      case '3366FF':
        return 'Blue';
      case 'FFB703':
        return 'Yellow';
      case '8384EF':
        return 'Purple';
      case 'FE644A':
        return 'Red Orange';
      case '10B8FB':
        return 'Light Blue';
      case '88961B':
        return 'Olive';
      case '0D99FA':
        return 'Bright Blue';
      default:
        return 'Custom';
    }
  }

  // Check if a color is dark (for determining text color)
  static bool isDarkColor(String hexString) {
    final color = getColor(hexString);
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  // Get appropriate text color (white or black) for a given background color
  static Color getTextColor(String hexString) {
    return isDarkColor(hexString) ? Colors.white : Colors.black87;
  }
}
