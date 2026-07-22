import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/review_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../data/profile_mock.dart';

/// Tradesman Profile tab.
///
/// Shows the tradesman's own profile preview, stats, reviews, and links to
/// edit the profile or sign out.
class TradesmanProfileScreen extends ConsumerWidget {
  const TradesmanProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ProfileMock.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push(RouteNames.editProfile),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 20),
              _StatsRow(user: user),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(RouteNames.editProfile),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 24),
              Text('About', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(
                user.about ??
                    '${user.role} with ${user.yearsExp ?? 0}+ years experience.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              if (user.pastWorkUrls.isNotEmpty) ...[
                Text('Past Work', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                _PastWorkRow(imageUrls: user.pastWorkUrls),
                const SizedBox(height: 24),
              ],
              Text('Reviews', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              for (final review in Review.sample)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ReviewCard(review: review),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  context.go(RouteNames.onboarding);
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final Worker user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _Avatar(imageUrl: user.imageUrl, isVerified: user.isVerified),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _Chip(
                      label: user.role,
                      background: AppColors.secondary,
                      foreground: AppColors.onSecondary,
                    ),
                    _Chip(
                      label: user.isOpen ? 'Available' : 'Unavailable',
                      background: user.isOpen
                          ? AppColors.success
                          : AppColors.error,
                      foreground: AppColors.onPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${user.rating}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        ProfileMock.district,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${Formatters.formatNumber(user.hourlyRate)} Rwf/hr',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, required this.isVerified});

  final String imageUrl;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipOval(
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: AppColors.primaryLight,
              child: const Icon(
                Icons.person,
                color: AppColors.onPrimary,
                size: 40,
              ),
            ),
          ),
        ),
        if (isVerified)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified, color: AppColors.success, size: 22),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: foreground),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});

  final Worker user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(value: '${user.jobsDone ?? 0}', label: 'Jobs Done'),
        const SizedBox(width: 12),
        _StatCard(value: '${user.reviewCount}', label: 'Reviews'),
        const SizedBox(width: 12),
        _StatCard(value: '${user.yearsExp ?? 0}', label: 'Yrs Exp.'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PastWorkRow extends StatelessWidget {
  const _PastWorkRow({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < imageUrls.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _PortfolioImage(imageUrl: imageUrls[i]),
          ),
        ],
      ],
    );
  }
}

class _PortfolioImage extends StatelessWidget {
  const _PortfolioImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: AppColors.tertiary,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
