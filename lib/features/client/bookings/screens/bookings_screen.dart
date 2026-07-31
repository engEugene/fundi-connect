import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../core/models/booking.dart';
import '../providers/booking_providers.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = const [
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

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(clientBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
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
      body: bookingsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const Center(
          child: Text("Couldn't load your bookings. Please try again."),
        ),
        data: (bookings) {
          List<Booking> forStatus(BookingStatus status) =>
              bookings.where((b) => b.status == status).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingList(
                bookings: forStatus(BookingStatus.upcoming),
                showRecentlyCompletedHeader: false,
              ),
              _BookingList(
                bookings: forStatus(BookingStatus.completed),
                showRecentlyCompletedHeader: true,
              ),
              _BookingList(
                bookings: forStatus(BookingStatus.cancelled),
                showRecentlyCompletedHeader: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({
    required this.bookings,
    required this.showRecentlyCompletedHeader,
  });

  final List<Booking> bookings;
  final bool showRecentlyCompletedHeader;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length + (showRecentlyCompletedHeader ? 1 : 0),
      itemBuilder: (context, index) {
        if (showRecentlyCompletedHeader) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'RECENTLY COMPLETED',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BookingCard(booking: bookings[index - 1]),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BookingCard(booking: bookings[index]),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

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

  Color get _statusBgColor {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return AppColors.primary.withValues(alpha: 0.08);
      case BookingStatus.completed:
        return AppColors.successLight;
      case BookingStatus.cancelled:
        return AppColors.errorLight;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get _formattedDate {
    final date = booking.date;
    final day = _weekdayShort(date.weekday);
    final month = _monthShort(date.month);
    final time = booking.time.isEmpty ? '' : ' · ${booking.time}';
    return '$day, ${date.day} $month$time';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteNames.bookingDetailPath(booking.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(imageUrl: booking.worker.imageUrl),
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
                        const SizedBox(height: 4),
                        Text(booking.worker.role, style: AppTextStyles.bodySmall),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _formattedDate,
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
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: _statusLabel,
                    backgroundColor: _statusBgColor,
                    foregroundColor: _statusColor,
                  ),
                ],
              ),
              if (booking.status == BookingStatus.completed && !booking.isRated) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(RouteNames.leaveReviewPath(booking.id)),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Rate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.divider),
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 56,
      height: 56,
      color: AppColors.tertiary,
      child: const Icon(Icons.person, color: AppColors.textMuted),
    );

    return ClipOval(
      child: imageUrl.isEmpty
          ? fallback
          : Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
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
            Icons.calendar_month_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings here yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayShort(int weekday) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[weekday - 1];
}

String _monthShort(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[month - 1];
}
