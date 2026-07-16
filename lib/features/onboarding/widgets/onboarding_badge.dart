import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

/// A small floating pill used to decorate the onboarding hero illustration
/// (rating, verification, price, location, etc.)
class OnboardingBadge extends StatelessWidget {
  const OnboardingBadge({
    super.key,
    this.icon,
    this.label,
    this.child,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.iconSize = 14,
    this.iconTrailing = false,
  }) : assert(child != null || label != null);

  final IconData? icon;
  final String? label;
  final Widget? child;
  final Color backgroundColor;
  final Color? foregroundColor;
  final double iconSize;

  /// If true, the icon is drawn after the label instead of before it
  /// (matches the "4.9 ★" ordering on the rating badge).
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppColors.textPrimary;
    final iconWidget = icon == null
        ? null
        : Icon(icon, size: iconSize, color: fg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidget != null && !iconTrailing) ...[
                iconWidget,
                const SizedBox(width: 5),
              ],
              Text(
                label!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              if (iconWidget != null && iconTrailing) ...[
                const SizedBox(width: 5),
                iconWidget,
              ],
            ],
          ),
    );
  }
}

/// Row of 5 stars used on the "rate and review" onboarding page.
class OnboardingStarRow extends StatelessWidget {
  const OnboardingStarRow({super.key, this.filled = 0});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return OnboardingBadge(
      backgroundColor: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final isFilled = i < filled;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              isFilled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 14,
              color: AppColors.secondary,
            ),
          );
        }),
      ),
    );
  }
}