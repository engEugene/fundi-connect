import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/utils/formatters.dart';
import '../../../client/bookings/providers/booking_providers.dart';

/// Full-screen view of a job request for the tradesman.
///
/// Shows the client details, job description, location and price, and lets
/// the tradesman accept or decline the request.
class TradesmanJobRequestDetailScreen extends ConsumerStatefulWidget {
  const TradesmanJobRequestDetailScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  @override
  ConsumerState<TradesmanJobRequestDetailScreen> createState() =>
      _TradesmanJobRequestDetailScreenState();
}

class _TradesmanJobRequestDetailScreenState
    extends ConsumerState<TradesmanJobRequestDetailScreen> {
  bool _processing = false;

  Future<void> _respond(String status) async {
    if (_processing) return;
    setState(() => _processing = true);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(widget.bookingId, status: status);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(workerBookingsProvider).value ?? const <Booking>[];
    final booking = requests.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => Booking(
        id: widget.bookingId,
        worker: const Worker(
          id: '',
          name: '',
          role: '',
          category: '',
          imageUrl: '',
          rating: 0,
          reviewCount: 0,
          distanceKm: 0,
          hourlyRate: 0,
        ),
        serviceType: '',
        date: DateTime.now(),
        time: '',
        location: '',
        status: BookingStatus.upcoming,
      ),
    );

    final isPending = booking.statusRaw == BookingLifecycle.pending;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Job Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ClientHeader(booking: booking),
              const SizedBox(height: 24),
              _InfoCard(booking: booking),
              const SizedBox(height: 24),
              Text('Job Description', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Text(
                booking.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text('Price', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${Formatters.formatNumber(booking.total)} Rwf',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (isPending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _processing
                            ? null
                            : () => _respond(BookingLifecycle.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _processing
                            ? null
                            : () => _respond(BookingLifecycle.accepted),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Accept Job'),
                      ),
                    ),
                  ],
                )
              else if (booking.statusRaw == BookingLifecycle.accepted)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Accepted',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _processing
                            ? null
                            : () => _respond(BookingLifecycle.completed),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Completed'),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    booking.statusRaw == BookingLifecycle.accepted
                        ? 'Accepted'
                        : booking.statusRaw == BookingLifecycle.rejected
                            ? 'Declined'
                            : 'Request ${booking.statusRaw}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: booking.statusRaw == BookingLifecycle.accepted
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.booking});

  final Booking booking;

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
          ClipOval(
            child: Image.network(
              booking.clientImageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64,
                height: 64,
                color: AppColors.primaryLight,
                child: const Icon(
                  Icons.person,
                  color: AppColors.onPrimary,
                  size: 32,
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
                  booking.clientName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.serviceType,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.8),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.booking});

  final Booking booking;

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${booking.date.day} ${months[booking.date.month - 1]} · ${booking.time}';
  }

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
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date & Time',
            value: _formattedDate,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: booking.location,
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Estimated Hours',
            value: '${booking.estimatedHours} hrs',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
