import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../data/onboarding_page_data.dart';
import '../widgets/onboarding_hero.dart';

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
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingPageBody(data: _pages[index]);
                },
              ),
            ),
            _OnboardingBottomSheet(
              pageCount: _pages.length,
              currentPage: _currentPage,
              primaryLabel: page.primaryLabel,
              showSignInPrompt: page.showSignInPrompt,
              showSkip: page.showSkip,
              onPrimaryPressed: _onPrimaryPressed,
              onSkip: _goToRoleSelect,
              onSignIn: () => context.go(RouteNames.signIn),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageBody extends StatelessWidget {
  const _OnboardingPageBody({required this.data});

  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OnboardingHero(imageAsset: data.imageAsset, badges: data.badges),
          const SizedBox(height: 20),
          Text.rich(
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
                      height: 1.25,
                    ),
                  ),
                  if (line != data.titleLines.last) const TextSpan(text: '\n'),
                ],
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.onboardingBody,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _OnboardingBottomSheet extends StatelessWidget {
  const _OnboardingBottomSheet({
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
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPrimaryPressed,
            child: Text(primaryLabel),
          ),
          const SizedBox(height: 14),
          if (showSignInPrompt)
            Text.rich(
              TextSpan(
                text: 'Already have an account? ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onSignIn,
                  ),
                ],
              ),
            )
          else if (showSkip)
            TextButton(onPressed: onSkip, child: const Text('Skip'))
          else
            const SizedBox(height: 20),
        ],
      ),
    );
  }
}