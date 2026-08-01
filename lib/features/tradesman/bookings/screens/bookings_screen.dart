import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../../../../core/utils/formatters.dart';
import '../../../client/bookings/providers/booking_providers.dart';

/// Tradesman Bookings tab.
///
/// Lists job requests grouped by status so the tradesman can accept, manage
/// and complete their jobs.
class TradesmanBookingsScreen extends ConsumerStatefulWidget {
  const TradesmanBookingsScreen({super.key});

  @override
  ConsumerState<TradesmanBookingsScreen> createState() =>
      _TradesmanBookingsScreenState();
}

class _TradesmanBookingsScreenState extends ConsumerState<TradesmanBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = const [
    Tab(text: 'Requests'),
    Tab(text: 'Upcoming'),
    Tab(text: 'Completed'),
    Tab(text: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _forTab(List<Booking> all, int index) {
    switch (index) {
      case 0:
        return all.where((b) => b.statusRaw == BookingLifecycle.pending).toList();
      case 1:
        return all
            .where((b) =>
                b.statusRaw == BookingLifecycle.accepted ||
                b.statusRaw == BookingLifecycle.inProgress)
            .toList();
      case 2:
        return all
            .where((b) => b.statusRaw == BookingLifecycle.completed)
            .toList();
      default:
        return all
            .where((b) =>
                b.statusRaw == BookingLifecycle.cancelled ||
                b.statusRaw == BookingLifecycle.rejected)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(workerBookingsProvider).value ?? const <Booking>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Jobs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelStyle: AppTextStyles.labelLarge,
          unselectedLabelStyle: AppTextStyles.labelLarge,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          dividerHeight: 0,
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _BookingList(
              bookings: _forTab(bookings, i),
              showActions: i == 0,
            ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    this.showActions = false,
  });

  final List<Booking> bookings;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _JobCard(
            booking: bookings[index],
            showActions: showActions,
            onTap: () => context.push(
              '${RouteNames.bookings}/${bookings[index].id}',
            ),
          ),
        );
      },
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({
    required this.booking,
    this.showActions = false,
    required this.onTap,
  });

  final Booking booking;
  final bool showActions;
  final VoidCallback onTap;

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${booking.date.day} ${months[booking.date.month - 1]} · ${booking.time}';
  }

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (booking.statusRaw) {
      case BookingLifecycle.pending:
        return 'Pending';
      case BookingLifecycle.accepted:
        return 'Accepted';
      case BookingLifecycle.inProgress:
        return 'In Progress';
      case BookingLifecycle.completed:
        return 'Completed';
      case BookingLifecycle.rejected:
        return 'Declined';
      default:
        return 'Cancelled';
    }
  }

  Future<void> _respond(WidgetRef ref, String status) async {
    final messenger = ScaffoldMessenger.of(ref.context);
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(booking.id, status: status);
    } catch (_) {
      if (ref.context.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _statusColor,
                      ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${Formatters.formatNumber(booking.total)} Rwf',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _respond(ref, BookingLifecycle.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _respond(ref, BookingLifecycle.accepted),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs here yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
