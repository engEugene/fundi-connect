import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../widgets/onboarding_badge.dart';
import '../widgets/onboarding_layout.dart';

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

///
/// Badge positions come from [OnboardingLayout], measured directly from
/// the Figma export. All 3 pages share that exact geometry — only the
/// copy/icons in each slot differ here.
List<OnboardingPageData> buildOnboardingPages() {
  return [
    // Page 1 — Find trusted tradesmen near you
    OnboardingPageData(
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
      badges: [
        OnboardingLayout.topLeft(
          child: const OnboardingBadge(
            icon: Icons.star_rounded,
            label: '4.9',
            iconTrailing: true,
          ),
        ),
        OnboardingLayout.topRight(
          child: const OnboardingBadge(
            icon: Icons.bolt_rounded,
            label: 'Plumber',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
        OnboardingLayout.overlap(
          child: const OnboardingBadge(
            icon: Icons.build_rounded,
            label: 'Verified',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
        OnboardingLayout.extra(
          child: const OnboardingBadge(
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
        OnboardingLayout.topLeft(
          child: const OnboardingBadge(label: 'Today, 2:00 PM'),
        ),
        OnboardingLayout.topRight(
          child: const OnboardingBadge(
            icon: Icons.account_balance_wallet_rounded,
            label: '5,000 Rwf',
          ),
        ),
        OnboardingLayout.overlap(
          child: const OnboardingBadge(
            icon: Icons.check_circle_rounded,
            label: 'Booked!',
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
        ),
        OnboardingLayout.extra(
          child: const OnboardingBadge(
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
        OnboardingLayout.topLeft(
          child: const OnboardingStarRow(filled: 0),
        ),
        OnboardingLayout.topRight(
          child: const OnboardingBadge(
            icon: Icons.thumb_up_rounded,
            label: '98%',
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
        ),
        OnboardingLayout.extra(
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