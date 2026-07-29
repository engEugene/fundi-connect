import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/utils/formatters.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  bool _isAvailable = true;

  final List<Booking> _upcomingJobs = Booking.all
      .where((b) => b.status == BookingStatus.upcoming)
      .toList();

  final double _todayEarnings = 18000;
  final double _weeklyEarnings = 94500;
  final double _monthlyEarnings = 342000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvailabilityCard(
                isAvailable: _isAvailable,
                onToggle: (value) => setState(() => _isAvailable = value),
              ),
              const SizedBox(height: 24),
              _EarningsSection(
                today: _todayEarnings,
                weekly: _weeklyEarnings,
                monthly: _monthlyEarnings,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Upcoming Jobs',
                count: _upcomingJobs.length,
              ),
              const SizedBox(height: 12),
              for (final job in _upcomingJobs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _JobCard(booking: job),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    required this.onToggle,
  });

  final bool isAvailable;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAvailable ? 'Available' : 'Unavailable',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAvailable
                        ? 'You are visible to clients'
                        : 'Clients cannot book you right now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Switch(
                value: isAvailable,
                onChanged: onToggle,
                activeThumbColor: AppColors.onPrimary,
                activeTrackColor: AppColors.success,
                inactiveThumbColor: AppColors.onPrimary,
                inactiveTrackColor: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? AppColors.success : AppColors.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isAvailable ? 'Accepting bookings' : 'Not accepting bookings',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsSection extends StatelessWidget {
  const _EarningsSection({
    required this.today,
    required this.weekly,
    required this.monthly,
  });

  final double today;
  final double weekly;
  final double monthly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Earnings', style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _EarningsCard(
                label: 'Today',
                amount: today,
                icon: Icons.today_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EarningsCard(
                label: 'This Week',
                amount: weekly,
                icon: Icons.calendar_view_week_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _EarningsCard(
          label: 'This Month',
          amount: monthly,
          icon: Icons.calendar_month_outlined,
          isWide: true,
        ),
      ],
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.label,
    required this.amount,
    required this.icon,
    this.isWide = false,
  });

  final String label;
  final double amount;
  final IconData icon;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${Formatters.formatNumber(amount)} Rwf',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.booking});

  final Booking booking;

  String get _formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${booking.date.day} ${months[booking.date.month - 1]} · ${booking.time}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    booking.worker.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.tertiary,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.worker.name,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.serviceType,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${Formatters.formatNumber(booking.total)} Rwf',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedDate,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.location,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
