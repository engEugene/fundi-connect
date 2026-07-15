import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/models/review.dart';
import '../../../core/models/worker.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/review_card.dart';


class WorkerDetailScreen extends StatelessWidget {
  const WorkerDetailScreen({super.key, required this.workerId});

  final String workerId;

  @override
  Widget build(BuildContext context) {
    final worker = Worker.findById(workerId);

    if (worker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Worker not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: _BookNowBar(worker: worker),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _ProfileHeader(worker: worker),
              const SizedBox(height: 20),
              _StatsRow(worker: worker),
              const SizedBox(height: 24),
              _SectionTitle('About'),
              const SizedBox(height: 8),
              Text(
                worker.about ??
                    '${worker.role} with ${worker.yearsExp ?? 0}+ years experience.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle('Reviews'),
              const SizedBox(height: 12),
              Column(
                children: Review.sample
                    .map((review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReviewCard(review: review),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.worker});

  final Worker worker;

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
          _Avatar(imageUrl: worker.imageUrl, isVerified: worker.isVerified),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _StatusChip(
                      label: worker.role,
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onSecondary,
                    ),
                    _StatusChip(
                      label: worker.isOpen ? 'Available' : 'Unavailable',
                      backgroundColor: worker.isOpen
                          ? AppColors.success
                          : AppColors.error,
                      foregroundColor: AppColors.onPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.rating}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on,
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${worker.distanceKm} km',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${Formatters.formatNumber(worker.hourlyRate)} Rwf/hr',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
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
            child: const Icon(
              Icons.verified,
              color: AppColors.success,
              size: 22,
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: '${worker.jobsDone ?? 0}',
          label: 'Jobs Done',
        ),
        const SizedBox(width: 12),
        _StatCard(
          value: '${worker.reviewCount}',
          label: 'Reviews',
        ),
        const SizedBox(width: 12),
        _StatCard(
          value: '${worker.yearsExp ?? 0}',
          label: 'Yrs Exp.',
        ),
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
            Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleMedium,
    );
  }
}

class _BookNowBar extends StatelessWidget {
  const _BookNowBar({required this.worker});

  final Worker worker;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: () => context.push(RouteNames.confirmBooking),
          child: const Text('Book Now'),
        ),
      ),
    );
  }
}
