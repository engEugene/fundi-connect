import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../data/onboarding_page_data.dart';
import '../widgets/onboarding_layout.dart';

/// Owner: Onboarding team (Feature 1)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = buildOnboardingPages();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToRoleSelect() => context.go(RouteNames.roleSelect);

  void _onPrimaryPressed() {
    final isLast = _currentPage == _pages.length - 1;
    if (isLast) {
      _goToRoleSelect();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            return _OnboardingCanvasPage(
              data: _pages[index],
              pageCount: _pages.length,
              currentPage: _currentPage,
              onPrimaryPressed: _onPrimaryPressed,
              onSkip: _goToRoleSelect,
              onSignIn: () => context.go(RouteNames.signIn),
            );
          },
        ),
      ),
    );
  }
}

/// Renders one onboarding page on a fixed 312x679 design canvas — matching
/// the measured Figma export exactly — then scales the whole canvas
/// uniformly to fit the device width via [FittedBox].
///
/// This trades perfect responsiveness for exact visual fidelity to the
/// design, which is the goal for a marketing/onboarding screen like this.
class _OnboardingCanvasPage extends StatelessWidget {
  const _OnboardingCanvasPage({
    required this.data,
    required this.pageCount,
    required this.currentPage,
    required this.onPrimaryPressed,
    required this.onSkip,
    required this.onSignIn,
  });

  final OnboardingPageData data;
  final int pageCount;
  final int currentPage;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSkip;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: OnboardingLayout.canvasWidth,
        height: OnboardingLayout.canvasHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Avatar
            Positioned(
              top: OnboardingLayout.avatarTop,
              left: OnboardingLayout.avatarLeft,
              child: SizedBox(
                width: OnboardingLayout.avatarSize,
                height: OnboardingLayout.avatarSize,
                child: Image.asset(
                  data.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                    ),
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

            ...data.badges,

            // Headline
            Positioned(
              top: OnboardingLayout.headlineTop,
              left: OnboardingLayout.headlineHorizontalPadding,
              right: OnboardingLayout.headlineHorizontalPadding,
              child: Text.rich(
                TextSpan(
                  children: [
                    for (final line in data.titleLines) ...[
                      TextSpan(
                        text: line.text,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: line.accent
                              ? AppColors.secondary
                              : AppColors.textOnDark,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      if (line != data.titleLines.last)
                        const TextSpan(text: '\n'),
                    ],
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Subtitle
            Positioned(
              top: OnboardingLayout.subtitleTop,
              left: OnboardingLayout.subtitleHorizontalPadding,
              right: OnboardingLayout.subtitleHorizontalPadding,
              child: Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.onboardingBody,
              ),
            ),

            // Bottom sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: OnboardingLayout.sheetHeight,
              child: _BottomSheet(
                pageCount: pageCount,
                currentPage: currentPage,
                primaryLabel: data.primaryLabel,
                showSignInPrompt: data.showSignInPrompt,
                showSkip: data.showSkip,
                onPrimaryPressed: onPrimaryPressed,
                onSkip: onSkip,
                onSignIn: onSignIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.pageCount,
    required this.currentPage,
    required this.primaryLabel,
    required this.showSignInPrompt,
    required this.showSkip,
    required this.onPrimaryPressed,
    required this.onSkip,
    required this.onSignIn,
  });

  final int pageCount;
  final int currentPage;
  final String primaryLabel;
  final bool showSignInPrompt;
  final bool showSkip;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSkip;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: OnboardingLayout.sheetTopPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pageCount, (index) {
              final isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: OnboardingLayout.sheetGapDotsToButton),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: OnboardingLayout.buttonHorizontalMargin,
            ),
            child: ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  OnboardingLayout.buttonHeight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(primaryLabel),
            ),
          ),
          const SizedBox(height: OnboardingLayout.sheetGapButtonToLink),
          if (showSignInPrompt)
            Text.rich(
              TextSpan(
                text: 'Already have an account? ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onSignIn,
                  ),
                ],
              ),
            )
          else if (showSkip)
            GestureDetector(
              onTap: onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}