import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/models/booking.dart';
import '../../client/bookings/providers/booking_providers.dart';
import '../domain/rating_math.dart';
import '../providers/review_providers.dart';
import '../widgets/star_rating.dart';

/// Form a client fills in to rate a completed booking.
///
/// Reached from the Bookings list and from the booking detail screen. All state
/// (stars, comment, submitting, error) lives in [reviewFormProvider]; this
/// widget holds only the [TextEditingController] the framework requires.
class LeaveReviewScreen extends ConsumerStatefulWidget {
  const LeaveReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await ref
        .read(reviewFormProvider.notifier)
        .submit(bookingId: widget.bookingId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanks! Your review has been posted.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    // Surface write failures as a SnackBar without losing what was typed.
    ref.listen<ReviewFormState>(reviewFormProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Rate your tradesman')),
      body: bookingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) => const _CenteredMessage(
          "Couldn't load this booking. Please try again.",
        ),
        data: (booking) {
          if (booking == null) {
            return const _CenteredMessage('Booking not found.');
          }
          if (booking.status != BookingStatus.completed) {
            return const _CenteredMessage(
              'You can rate this job once it has been completed.',
            );
          }
          if (booking.isRated) {
            return const _CenteredMessage(
              'You have already reviewed this booking. Thank you!',
            );
          }
          return _ReviewForm(
            booking: booking,
            commentController: _commentController,
            onSubmit: _submit,
          );
        },
      ),
    );
  }
}

class _ReviewForm extends ConsumerWidget {
  const _ReviewForm({
    required this.booking,
    required this.commentController,
    required this.onSubmit,
  });

  final Booking booking;
  final TextEditingController commentController;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(reviewFormProvider);
    final notifier = ref.read(reviewFormProvider.notifier);

    return SafeArea(
      // Scrollable so the form does not overflow in landscape or on a small
      // screen once the keyboard is up.
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _WorkerSummary(booking: booking),
          const SizedBox(height: 32),
          Text(
            'How was the job?',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 20),
          StarRatingInput(
            value: form.rating,
            enabled: !form.isSubmitting,
            onChanged: notifier.setRating,
          ),
          const SizedBox(height: 32),
          Text('Add a comment (optional)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            enabled: !form.isSubmitting,
            maxLines: 5,
            maxLength: RatingMath.maxCommentLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: notifier.setComment,
            decoration: const InputDecoration(
              hintText: 'Tell other clients what the work was like…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your name and photo will be shown with this review.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: form.canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: form.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}

/// Reminds the client who and what they are rating.
class _WorkerSummary extends StatelessWidget {
  const _WorkerSummary({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final worker = booking.worker;
    final fallback = Container(
      width: 64,
      height: 64,
      color: AppColors.tertiaryDark,
      child: const Icon(Icons.person, color: AppColors.textMuted),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipOval(
            child: worker.imageUrl.isEmpty
                ? fallback
                : Image.network(
                    worker.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => fallback,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.serviceType.isEmpty
                      ? worker.role
                      : booking.serviceType,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
