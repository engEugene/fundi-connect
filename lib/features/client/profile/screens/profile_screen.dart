import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/widgets/profile_widgets.dart';
import '../../../../core/widgets/review_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../reviews/providers/review_providers.dart';

/// Client profile tab.
///
/// Shows the signed-in client's details (name, email, phone) and a summary of
/// their account activity.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.authenticatedUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(user: user),
                    const SizedBox(height: 20),
                    _ContactCard(user: user),
                    const SizedBox(height: 20),
                    _ActionRow(
                      onEdit: () => context.push(RouteNames.editProfile),
                      onSettings: () => context.push(RouteNames.settings),
                    ),
                    const SizedBox(height: 24),

                    const ProfileSectionTitle('Reviews You Have Written'),
                    const SizedBox(height: 12),
                    const _MyWrittenReviews(),
                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(RouteNames.onboarding);
                        }
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Log Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Live list of the reviews the signed-in client has left for tradesmen.
class _MyWrittenReviews extends ConsumerWidget {
  const _MyWrittenReviews();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myWrittenReviewsProvider);

    return reviewsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, _) => Text(
        "Couldn't load your reviews.",
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
      ),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Text(
            "You haven't reviewed anyone yet. Rate a tradesman after a "
            'completed job to help other clients.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          );
        }
        return Column(
          children: [
            for (final review in reviews)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewCard(review: review),
              ),
          ],
        );
      },
    );
  }
}

/// Navy card holding avatar, name and account summary.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final name = user.displayName ?? 'Client';
    final initials = name.isNotEmpty
        ? name.split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : 'C';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.primaryLight,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Client account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                _Chip(
                  label: 'Verified',
                  background: AppColors.success,
                  foreground: AppColors.onPrimary,
                  icon: Icons.verified,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _ContactRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email ?? 'Not set',
          ),
          const Divider(height: 24),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: user.phone ?? 'Not set',
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Edit / Settings shortcuts sitting under the contact card.
class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onEdit, required this.onSettings});

  final VoidCallback onEdit;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('Settings'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ],
    );
  }
}
