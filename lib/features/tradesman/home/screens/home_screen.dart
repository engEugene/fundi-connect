import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../client/bookings/providers/booking_providers.dart';
import '../../../client/profile/providers/profile_provider.dart';

/// Tradesman entry point.
///
/// Shows incoming job requests, availability toggle, and quick stats so a

class TradesmanHomeScreen extends ConsumerStatefulWidget {
  const TradesmanHomeScreen({super.key});

  @override
  ConsumerState<TradesmanHomeScreen> createState() => _TradesmanHomeScreenState();
}

class _TradesmanHomeScreenState extends ConsumerState<TradesmanHomeScreen> {
  bool _savingAvailability = false;

  Future<void> _toggleAvailability(bool value) async {
    final uid = ref.read(authProvider).authenticatedUser?.uid;
    if (uid == null || _savingAvailability) return;
    setState(() => _savingAvailability = true);
    try {
      await ref
          .read(workerProfileRepositoryProvider)
          .updateAvailability(uid: uid, isOpen: value);
      ref.invalidate(workerProfileProvider);
    } finally {
      if (mounted) setState(() => _savingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(workerBookingsProvider);
    final profileAsync = ref.watch(workerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _GreetingHeader(),
              const SizedBox(height: 24),
              profileAsync.when(
                loading: () => const _AvailabilityCard(
                  isAvailable: false,
                  onToggle: null,
                ),
                error: (_, _) => const _AvailabilityCard(
                  isAvailable: false,
                  onToggle: null,
                ),
                data: (profile) => _AvailabilityCard(
                  isAvailable: profile?.isOpen ?? false,
                  onToggle: _savingAvailability ? null : _toggleAvailability,
                ),
              ),
              const SizedBox(height: 24),
              _QuickStatsRow(
                profile: profileAsync.valueOrNull,
                bookings: requestsAsync.value ?? const [],
                onTap: () => context.push(RouteNames.workerDashboard),
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Incoming Requests',
                count: requestsAsync.value?.length ?? 0,
                onActionTap: () => context.go(RouteNames.bookings),
              ),
              const SizedBox(height: 16),
              requestsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (_, _) => const _EmptyRequestsState(),
                data: (requests) {
                  final pending = requests
                      .where((b) => b.statusRaw == BookingLifecycle.pending)
                      .toList();
                  if (pending.isEmpty) return const _EmptyRequestsState();
                  return Column(
                    children: [
                      for (final booking in pending)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RequestCard(
                            booking: booking,
                            onTap: () => context.push(
                              '${RouteNames.bookings}/${booking.id}',
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.select((s) => s.authenticatedUser));
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'there';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello 👋',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayName,
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Tradesman',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.tertiary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    this.onToggle,
  });

  final bool isAvailable;
  final ValueChanged<bool>? onToggle;

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
                        ? 'Clients can book you right now'
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

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({
    required this.profile,
    required this.bookings,
    this.onTap,
  });

  final Worker? profile;
  final List<Booking> bookings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final completed = bookings
        .where((b) => b.statusRaw == BookingLifecycle.completed)
        .toList();
    final earnings =
        completed.fold<double>(0, (sum, b) => sum + b.serviceFee);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          _StatCard(
            label: 'Earnings',
            value: '${Formatters.formatNumber(earnings)} Rwf',
            icon: Icons.today_outlined,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Rating',
            value: (profile?.rating ?? 0).toStringAsFixed(1),
            icon: Icons.star_outline,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Jobs',
            value: '${completed.length}',
            icon: Icons.work_outline,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    this.onActionTap,
  });

  final String title;
  final int count;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(width: 8),
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
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            'View all',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.booking,
    required this.onTap,
  });

  final Booking booking;
  final VoidCallback onTap;

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${booking.date.day} ${months[booking.date.month - 1]} · ${booking.time}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceType,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.clientName,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
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
                    size: 14,
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
      ),
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            'No requests yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check the Discover tab for tips',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
