import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_widgets.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider.select((s) => s.selectedRole));
    final notifier = ref.read(authProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AuthStyles.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: AppColors.onPrimary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'How will you use\nFundi Connect?',
                        style: AppTextStyles.displayMedium.copyWith(
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Choose your role to get started',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _RoleCard(
                        title: 'I need a tradesman',
                        subtitle: 'Post jobs and hire skilled workers near you',
                        icon: Icons.person_search_rounded,
                        selected: role == UserRole.client,
                        onTap: () => notifier.selectRole(UserRole.client),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: 'I am a tradesman',
                        subtitle: 'Offer your skills and grow your business',
                        icon: Icons.handyman_rounded,
                        selected: role == UserRole.worker,
                        onTap: () => notifier.selectRole(UserRole.worker),
                      ),
                      const SizedBox(height: 24),
                      const InfoNote(
                        message:
                            'You can switch roles anytime from your profile '
                            'settings.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              AuthSubmitButton(
                label: role == UserRole.worker
                    ? 'Continue as Tradesman'
                    : 'Continue as Client',
                // push so back arrow goes back here
                onPressed: () => context.push(RouteNames.createAccount),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $subtitle',
      // stops screen reader from saying it twice
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? AppColors.tertiary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary
                          : AppColors.tertiaryDark,
                    ),
                    child: Icon(
                      icon,
                      size: 26,
                      color: selected
                          ? AppColors.onPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 22,
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? AppColors.primaryLight
                                : AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
