import 'package:flutter/material.dart';

/// App color palette derived from the Fundi Connect Figma design.
///
/// Replace the hex values below with the exact tokens from Figma's inspect panel.
class AppColors {
  AppColors._();

  // Primary palette (deep navy blue used on onboarding, buttons, headers)
  static const Color primary = Color(0xFF1E2772);
  static const Color primaryLight = Color(0xFF3B4AA1);
  static const Color primaryDark = Color(0xFF13194D);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary palette (gold/yellow accents, ratings, badges)
  static const Color secondary = Color(0xFFF5B800);
  static const Color secondaryLight = Color(0xFFFFD54F);
  static const Color secondaryDark = Color(0xFFC68E00);
  static const Color onSecondary = Color(0xFF1E2772);

  // Tertiary palette (soft backgrounds, chips, subtle highlights)
  static const Color tertiary = Color(0xFFF3F4F6);
  static const Color tertiaryDark = Color(0xFFE5E7EB);
  static const Color onTertiary = Color(0xFF1F2937);

  // Background & surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF9FAFB);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Semantic colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color errorBright = Color(0xFFFF5252);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Input fields
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color inputBorder = Color(0xFFE5E7EB);
  static const Color inputFocusedBorder = primary;

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Dividers & shadows
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
}
