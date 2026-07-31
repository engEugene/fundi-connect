import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/review.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/review_repository.dart';
import '../domain/rating_math.dart';

/// Single instance of the repository, injected so tests can override it.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

// -----------------------------------------------------------------------------
// Read providers
// -----------------------------------------------------------------------------

/// Every review a given tradesman has received. Used on the worker detail
/// screen and on the tradesman's own profile.
final workerReviewsProvider =
    StreamProvider.autoDispose.family<List<Review>, String>((ref, workerId) {
  if (workerId.isEmpty) return Stream.value(const []);
  return ref.watch(reviewRepositoryProvider).watchWorkerReviews(workerId);
});

/// Every review the signed-in client has written.
final myWrittenReviewsProvider =
    StreamProvider.autoDispose<List<Review>>((ref) {
  final uid = ref.watch(authProvider).authenticatedUser?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(reviewRepositoryProvider).watchClientReviews(uid);
});

/// The review attached to one booking, or null while it is still unrated.
final bookingReviewProvider =
    StreamProvider.autoDispose.family<Review?, String>((ref, bookingId) {
  return ref.watch(reviewRepositoryProvider).watchReviewForBooking(bookingId);
});

// -----------------------------------------------------------------------------
// Write state
// -----------------------------------------------------------------------------

/// State of the "leave a review" form.
///
/// Held in a Riverpod notifier rather than `setState` so the submit call, the
/// validation error and the success flag all live outside the widget — the
/// screen rebuilds from this and owns no mutable state of its own.
class ReviewFormState {
  const ReviewFormState({
    this.rating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.submittedReviewId,
  });

  /// Selected stars. 0 means the client has not chosen yet.
  final int rating;
  final String comment;
  final bool isSubmitting;
  final String? errorMessage;

  /// Set once the write lands, so the screen knows to pop with a success
  /// message instead of re-rendering the form.
  final String? submittedReviewId;

  /// The submit button stays disabled until a rating is picked.
  bool get canSubmit =>
      !isSubmitting &&
      RatingMath.isValidRating(rating) &&
      RatingMath.isValidComment(comment);

  bool get isSuccess => submittedReviewId != null;

  int get remainingCharacters =>
      RatingMath.maxCommentLength - comment.trim().length;

  ReviewFormState copyWith({
    int? rating,
    String? comment,
    bool? isSubmitting,
    String? errorMessage,
    String? submittedReviewId,
    bool clearError = false,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submittedReviewId: submittedReviewId ?? this.submittedReviewId,
    );
  }
}

/// Drives the review form: star selection, comment text and the submit call.
class ReviewFormNotifier extends AutoDisposeNotifier<ReviewFormState> {
  @override
  ReviewFormState build() => const ReviewFormState();

  void setRating(int rating) =>
      state = state.copyWith(rating: rating, clearError: true);

  void setComment(String comment) =>
      state = state.copyWith(comment: comment, clearError: true);

  /// Writes the review. Returns true on success so the caller can pop.
  Future<bool> submit({required String bookingId}) async {
    if (!state.canSubmit) return false;

    final user = ref.read(authProvider).authenticatedUser;
    if (user == null) {
      state = state.copyWith(
        errorMessage: 'Please sign in again to leave a review.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final reviewId = await ref.read(reviewRepositoryProvider).submitReview(
            bookingId: bookingId,
            clientId: user.uid,
            rating: state.rating,
            comment: state.comment,
            clientName: user.displayName ?? 'Client',
            clientPhotoUrl: user.photoUrl ?? '',
          );

      state = state.copyWith(isSubmitting: false, submittedReviewId: reviewId);
      return true;
    } on ReviewException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Could not save your review. Please try again.',
      );
      return false;
    }
  }
}

final reviewFormProvider =
    NotifierProvider.autoDispose<ReviewFormNotifier, ReviewFormState>(
  ReviewFormNotifier.new,
);
