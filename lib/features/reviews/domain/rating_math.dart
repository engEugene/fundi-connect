/// Pure rating-aggregation logic for the reviews feature.
///
/// This lives in `domain/` and has no Firebase, Flutter or Riverpod imports on
/// purpose: it is the part of the reviews feature that carries real business
/// rules, so keeping it free of I/O means it can be unit tested without an
/// emulator. [ReviewRepository] calls it from inside a Firestore transaction.
library;

/// The two aggregate fields denormalised onto a `workers/{uid}` document.
class RatingAggregate {
  const RatingAggregate({required this.average, required this.count});

  /// Mean of every rating the worker has received, rounded to 2 decimals.
  final double average;

  /// How many reviews the average was computed from.
  final int count;

  @override
  bool operator ==(Object other) =>
      other is RatingAggregate &&
      other.average == average &&
      other.count == count;

  @override
  int get hashCode => Object.hash(average, count);

  @override
  String toString() => 'RatingAggregate(average: $average, count: $count)';
}

/// Rating aggregation rules.
class RatingMath {
  RatingMath._();

  /// Lowest star value a client may submit.
  static const int minRating = 1;

  /// Highest star value a client may submit.
  static const int maxRating = 5;

  /// Longest comment accepted. Mirrored in `firestore.rules` so a rogue client
  /// cannot bypass the check by writing to Firestore directly.
  static const int maxCommentLength = 500;

  /// Folds one new [rating] into an existing average.
  ///
  /// Recomputes from the running total rather than reading every review
  /// document, which keeps the write to a single transaction no matter how many
  /// reviews a worker already has.
  ///
  /// Defensive against bad stored state: a negative [currentCount] or a
  /// non-finite [currentAverage] is treated as "no reviews yet" instead of
  /// poisoning the new average.
  static RatingAggregate applyNewRating({
    required double currentAverage,
    required int currentCount,
    required int rating,
  }) {
    assert(
      rating >= minRating && rating <= maxRating,
      'rating must be between $minRating and $maxRating',
    );

    final safeCount = currentCount > 0 ? currentCount : 0;
    final safeAverage =
        (safeCount > 0 && currentAverage.isFinite && currentAverage > 0)
            ? currentAverage
            : 0.0;

    final newCount = safeCount + 1;
    final newTotal = (safeAverage * safeCount) + rating;

    return RatingAggregate(
      average: roundToTwoDecimals(newTotal / newCount),
      count: newCount,
    );
  }

  /// Rounds to 2 decimal places so repeated transactions cannot accumulate
  /// floating-point drift in the stored `ratingAvg`.
  static double roundToTwoDecimals(double value) {
    if (!value.isFinite) return 0;
    return (value * 100).round() / 100;
  }

  /// Whether [rating] is a star value the app will accept.
  static bool isValidRating(int rating) =>
      rating >= minRating && rating <= maxRating;

  /// Whether [comment] is short enough to store. Empty comments are allowed —
  /// a star-only review is still useful.
  static bool isValidComment(String comment) =>
      comment.trim().length <= maxCommentLength;
}
