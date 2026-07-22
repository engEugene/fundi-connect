import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

/// Tradesman Discover tab.
///
/// For the MVP this is a tradesman-focused hub with tips on how to win more
/// jobs.
class TradesmanDiscoverScreen extends StatelessWidget {
  const TradesmanDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Grow your business',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tips to get more bookings and keep clients happy',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              const _TipCard(
                icon: Icons.star_outline,
                title: 'Keep your rating high',
                description:
                    'Complete jobs on time, communicate clearly, and ask happy clients to leave a review.',
              ),
              const SizedBox(height: 16),
              const _TipCard(
                icon: Icons.photo_camera_outlined,
                title: 'Add portfolio photos',
                description:
                    'Showcase your best work in your profile so clients trust your skills.',
              ),
              const SizedBox(height: 16),
              const _TipCard(
                icon: Icons.schedule_outlined,
                title: 'Update your availability',
                description:
                    'Set your working hours so clients know when they can book you.',
              ),
              const SizedBox(height: 16),
              const _TipCard(
                icon: Icons.local_offer_outlined,
                title: 'Price competitively',
                description:
                    'Check what other tradesmen in your area charge and adjust your rate.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(RouteNames.profile),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit My Profile'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.onPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
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
