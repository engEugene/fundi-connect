import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Decorative hero used at the top of each onboarding page: a circular
/// portrait with a gold ring, a soft glow behind it, and floating badges
/// positioned around it.
///
/// [badges] must already be wrapped in [Positioned] (or [Align]) widgets
/// since exact placement differs per page — see [buildOnboardingPages].
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({
    super.key,
    required this.imageAsset,
    required this.badges,
    this.height = 320,
    this.avatarSize = 128,
  });

  final String imageAsset;
  final List<Widget> badges;
  final double height;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Soft glow blob behind the avatar.
          Align(
            alignment: const Alignment(0, -0.05),
            child: Container(
              width: avatarSize + 110,
              height: avatarSize + 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
          // Avatar with gold ring.
          Align(
            alignment: const Alignment(0, -0.05),
            child: Container(
              width: avatarSize,
              height: avatarSize,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 3),
              ),
              child: ClipOval(
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryLight,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...badges,
        ],
      ),
    );
  }
}