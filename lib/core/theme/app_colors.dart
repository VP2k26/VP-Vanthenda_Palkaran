import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dairy Daily Brand Brown Palette (Warm Earthy tones)
  static const Color brandBrown = Color(0xFF4A2E18); // Main brand dark brown
  static const Color brandBrownLight = Color(
    0xFF7C5329,
  ); // Accent / Border brown
  static const Color textBrown = Color(0xFF5C4033); // Subtitle / Label brown

  // Primary Brand Colors
  static const Color primary = Color(0xFF4A2E18);
  static const Color primaryLight = Color(0xFF7C5329);
  static const Color primaryDark = Color(0xFF2E1C0E);

  // Vibrant accents
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFF60A5FA);

  // Success / Growth (Emerald)
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);

  // Background and Surface (Warm Cream Palette)
  static const Color backgroundLight = Color(0xFFF5F2CF); // Center glow
  static const Color background = Color(0xFFF5ECAB); // Base / Bottom tone
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // State colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Borders
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Custom properties
  static const Color subtleShadow = Color(0x0A0F172A);
  static const Color mediumShadow = Color(0x140F172A);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Radial background gradient with center glow
  static const RadialGradient backgroundGradient = RadialGradient(
    colors: [
      backgroundLight, // Center glow: Color(0xFFF5F2CF)
      background, // Outer edges: Color(0xFFF5ECAB)
    ],
    center: Alignment.center,
    radius: 0.85,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
