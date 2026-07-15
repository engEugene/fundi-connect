import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../widgets/onboarding_badge.dart';

/// One line of the onboarding headline, either white or accent (gold).
class TitleLine {
  const TitleLine(this.text, {this.accent = false});

  final String text;
  final bool accent;
}

class OnboardingPageData {
  const OnboardingPageData({
    required this.imageAsset,
    required this.badges,
    required this.titleLines,
    required this.subtitle,
    required this.primaryLabel,
    this.showSignInPrompt = false,
    this.showSkip = false,
  });

  final String imageAsset;
  final List<Widget> badges;
  final List<TitleLine> titleLines;
  final String subtitle;
  final String primaryLabel;
  final bool showSignInPrompt;
  final bool showSkip;
}

/// Owner: Onboarding team (Feature 1)
///
/// Badge positions are eyeballed from the Figma screenshots (no dev-mode
/// access) — nudge the `top`/`left`/`right` values here if anything sits
/// a few px off once you compare against the design on a real device.
List<OnboardingPageData> buildOnboardingPages() {
  return [
    // Page 1 — Find trusted tradesmen near you
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
      badges: [
        const Positioned(
          top: 36,
          left: 8,
          child: OnboardingBadge(
            icon: Icons.star_rounded,
            label: '4.9',
            iconTrailing: true,
          ),
        ),
        const Positioned(
          top: 78,
          right: 4,
          child: OnboardingBadge(
            icon: Icons.bolt_rounded,
            label: 'Plumber',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
        Positioned(
          top: 206,
          left: 0,
          right: 0,
          child: Align(
            alignment: const Alignment(-0.15, 0),
            child: const OnboardingBadge(
              icon: Icons.build_rounded,
              label: 'Verified',
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
            ),
          ),
        ),
        const Positioned(
          top: 238,
          right: 12,
          child: OnboardingBadge(
            icon: Icons.location_on_rounded,
            label: '0.8 km',
          ),
        ),
      ],
      titleLines: const [
        TitleLine('Find trusted'),
        TitleLine('tradesmen', accent: true),
        TitleLine('near you'),
      ],
      subtitle:
          'Connect with verified plumbers, electricians, carpenters and '
          'more — right in your neighbourhood.',
      primaryLabel: 'Get Started',
      showSignInPrompt: true,
    ),

    // Page 2 — Book instantly, pay securely
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/onboarding_2.png',
      badges: [
        const Positioned(
          top: 36,
          left: 8,
          child: OnboardingBadge(label: 'Today, 2:00 PM'),
        ),
        const Positioned(
          top: 78,
          right: 4,
          child: OnboardingBadge(
            icon: Icons.account_balance_wallet_rounded,
            label: '5,000 Rwf',
          ),
        ),
        Positioned(
          top: 206,
          left: 0,
          right: 0,
          child: Align(
            alignment: const Alignment(-0.15, 0),
            child: const OnboardingBadge(
              icon: Icons.check_circle_rounded,
              label: 'Booked!',
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const Positioned(
          top: 240,
          right: 8,
          child: OnboardingBadge(
            icon: Icons.shield_rounded,
            label: 'Secure Pay',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
      ],
      titleLines: const [
        TitleLine('Book instantly,'),
        TitleLine('pay securely', accent: true),
      ],
      subtitle:
          'Schedule jobs in seconds and pay safely via MoMo or card — '
          'no cash hassles.',
      primaryLabel: 'Next',
      showSkip: true,
    ),

    // Page 3 — Rate and review your tradesman
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/onboarding_3.png',
      badges: [
        const Positioned(
          top: 36,
          left: 8,
          child: OnboardingStarRow(filled: 0),
        ),
        const Positioned(
          top: 78,
          right: 4,
          child: OnboardingBadge(
            icon: Icons.thumb_up_rounded,
            label: '98%',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
        Positioned(
          top: 218,
          right: 4,
          child: OnboardingBadge(
            backgroundColor: AppColors.secondary,
            child: Text(
              '"Great work! Very fast."',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
      titleLines: const [
        TitleLine('Rate and review'),
        TitleLine('your tradesman', accent: true),
      ],
      subtitle:
          'Your feedback builds a trusted community. Help others find the '
          'best workers around.',
      primaryLabel: 'Continue',
      showSkip: true,
    ),
  ];
}