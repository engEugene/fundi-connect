import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/booking_providers.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Details')),
      body: bookingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const Center(
          child: Text("Couldn't load this booking. Please try again."),
        ),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }
          return _BookingDetailBody(booking: booking);
        },
      ),
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  const _BookingDetailBody({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WorkerCard(booking: booking),
            const SizedBox(height: 24),
            _StatusCard(booking: booking),
            const SizedBox(height: 24),
            _SectionTitle('Service Details'),
            const SizedBox(height: 12),
            _DetailItem(
              icon: Icons.handyman_outlined,
              label: 'Service Type',
              value: booking.serviceType.isEmpty ? '—' : booking.serviceType,
            ),
            _DetailItem(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: _formatDate(booking.date),
            ),
            _DetailItem(
              icon: Icons.access_time,
              label: 'Time',
              value: booking.time.isEmpty ? '—' : booking.time,
            ),
            _DetailItem(
              icon: Icons.location_on_outlined,
              label: 'Location',
              value: booking.location.isEmpty ? '—' : booking.location,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Price Estimate'),
            const SizedBox(height: 12),
            _PriceBreakdown(booking: booking),
            const SizedBox(height: 24),
            _SectionTitle('Payment Method'),
            const SizedBox(height: 12),
            _PaymentMethod(paymentMethod: booking.paymentMethod ?? 'Cash'),
            const SizedBox(height: 32),
            _ActionButtons(booking: booking),
          ],
        ),
      ),
    );
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.booking});

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
              booking.worker.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.onPrimary, size: 36),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.worker.name,
                  style: AppTextStyles.titleLarge.copyWith(color: AppColors.onPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.worker.role,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${booking.worker.rating}',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.onPrimary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${Formatters.formatNumber(booking.worker.hourlyRate)} Rwf/hr',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.secondary),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.booking});

  final Booking booking;

  Color get _color {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _label {
    switch (booking.statusRaw) {
      case BookingLifecycle.pending:
        return 'Waiting for the tradesman to accept';
      case BookingLifecycle.accepted:
        return 'Accepted — upcoming booking';
      case BookingLifecycle.inProgress:
        return 'Job in progress';
      case BookingLifecycle.completed:
        return 'Completed booking';
      case BookingLifecycle.rejected:
        return 'Declined by the tradesman';
      case BookingLifecycle.cancelled:
        return 'Cancelled booking';
      default:
        return 'Booking';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _label,
              style: AppTextStyles.bodyMedium.copyWith(color: _color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) =>
      Text(title, style: AppTextStyles.titleMedium);
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: 'Service fee',
            value: Formatters.formatNumber(booking.serviceFee),
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Platform fee',
            value: Formatters.formatNumber(booking.platformFee),
          ),
          const Divider(height: 24),
          _PriceRow(
            label: 'Total',
            value: Formatters.formatNumber(booking.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.titleMedium
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          '$value Rwf',
          style: isTotal
              ? AppTextStyles.titleMedium.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.paymentMethod});

  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(paymentMethod, style: AppTextStyles.bodyMedium)),
          Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

/// Status-dependent actions. The only wired action in this scope is Cancel
/// (client-side). Rate/reschedule land with the reviews track.
class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _isCancelling = false;

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancel booking?', style: AppTextStyles.titleLarge),
        content: Text(
          'This will notify the tradesman that you no longer need this job.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _isCancelling = true);

    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(widget.booking.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Booking cancelled')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not cancel. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.booking.status) {
      case BookingStatus.upcoming:
        return OutlinedButton(
          onPressed: _isCancelling ? null : _cancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          child: _isCancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.error,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Cancel Booking'),
        );
      case BookingStatus.completed:
        return ElevatedButton(
          onPressed: () {},
          child: const Text('Rate Worker'),
        );
      case BookingStatus.cancelled:
        return ElevatedButton(
          onPressed: () => context.push(
            '${RouteNames.confirmBooking}?workerId=${widget.booking.worker.id}',
          ),
          child: const Text('Book Again'),
        );
    }
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
