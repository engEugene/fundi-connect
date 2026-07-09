import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Central text styles for Fundi Connect.
///
/// Uses Google Fonts (Inter). Replace with the Figma font family if different.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
        height: 1.25,
        letterSpacing: -0.2,
      );

  // Display
  static TextStyle displayLarge = _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  // Headlines
  static TextStyle headlineLarge = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineMedium = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle headlineSmall = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Titles
  static TextStyle titleLarge = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleSmall = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // Body
  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels / buttons
  static TextStyle labelLarge = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelMedium = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static TextStyle labelSmall = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Special styles seen in the app
  static TextStyle onboardingHeadline = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnDark,
    height: 1.2,
  );

  static TextStyle onboardingBody = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark.withValues(alpha: 0.8),
    height: 1.5,
  );

  static TextStyle button = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  static TextStyle caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle price = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
