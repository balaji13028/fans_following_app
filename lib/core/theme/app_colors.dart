import 'package:flutter/material.dart';

/// App Color Scheme for Dark Theme
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  // Background Colors
  static const Color background = Color(0xFF000000); // Pure black
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color surfaceVariant = Color(0xFF212121); // Text field color
  static const Color card = Color(0xFF1F1F1F);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB3B3B3); // Light gray
  static const Color textTertiary = Color(0xFF808080); // Medium gray
  static const Color textDisabled = Color(0xFF4A4A4A); // Dark gray

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Border Colors
  static const Color border = Color(0xFF2C2929); // Border color
  static const Color borderLight = Color(0xFF3A3A3A);

  // Divider
  static const Color divider = Color(0xFF2A2A2A);

  // Overlay
  static const Color overlay = Color(0x80000000); // Black with 50% opacity

  // Shadow
  static const Color shadow = Color(0x40000000); // Black with 25% opacity

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

