import 'package:flutter_test/flutter_test.dart';
import 'package:fundi_connect/features/reviews/domain/rating_math.dart';

/// Unit tests for the rating aggregation rules.
///
/// These run without Firebase or a widget tree because [RatingMath] is pure —
/// that is the reason the logic lives in `domain/` instead of inside the
/// repository's transaction callback.
void main() {
  group('RatingMath.applyNewRating', () {
    test('first review becomes the average and sets the count to 1', () {
      final result = RatingMath.applyNewRating(
        currentAverage: 0,
        currentCount: 0,
        rating: 5,
      );

      expect(result.average, 5.0);
      expect(result.count, 1);
    });

    test('folds a new rating into an existing average', () {
      // One 4-star review already stored, a 2-star review comes in.
      final result = RatingMath.applyNewRating(
        currentAverage: 4.0,
        currentCount: 1,
        rating: 2,
      );

      expect(result.average, 3.0);
      expect(result.count, 2);
    });

    test('rounds the average to two decimal places', () {
      // (5 + 5 + 4) / 3 = 4.666..., stored as 4.67.
      final result = RatingMath.applyNewRating(
        currentAverage: 5.0,
        currentCount: 2,
        rating: 4,
      );

      expect(result.average, 4.67);
      expect(result.count, 3);
    });

    test('stays stable over a long run of identical ratings', () {
      var aggregate = const RatingAggregate(average: 0, count: 0);

      for (var i = 0; i < 50; i++) {
        aggregate = RatingMath.applyNewRating(
          currentAverage: aggregate.average,
          currentCount: aggregate.count,
          rating: 4,
        );
      }

      // Without the rounding step this drifts off 4.0 through float error.
      expect(aggregate.average, 4.0);
      expect(aggregate.count, 50);
    });

    test('treats a corrupt count as no reviews rather than poisoning the average',
        () {
      final result = RatingMath.applyNewRating(
        currentAverage: 4.5,
        currentCount: -3,
        rating: 5,
      );

      expect(result.average, 5.0);
      expect(result.count, 1);
    });

    test('never produces an average outside the 1-5 star range', () {
      final lowest = RatingMath.applyNewRating(
        currentAverage: 1,
        currentCount: 10,
        rating: 1,
      );
      final highest = RatingMath.applyNewRating(
        currentAverage: 5,
        currentCount: 10,
        rating: 5,
      );

      expect(lowest.average, greaterThanOrEqualTo(1));
      expect(highest.average, lessThanOrEqualTo(5));
    });
  });

  group('RatingMath validation', () {
    test('accepts every whole star from 1 to 5', () {
      for (var rating = 1; rating <= 5; rating++) {
        expect(RatingMath.isValidRating(rating), isTrue, reason: '$rating stars');
      }
    });

    test('rejects 0 stars and anything above 5', () {
      expect(RatingMath.isValidRating(0), isFalse);
      expect(RatingMath.isValidRating(6), isFalse);
      expect(RatingMath.isValidRating(-1), isFalse);
    });

    test('accepts an empty comment — a star-only review is allowed', () {
      expect(RatingMath.isValidComment(''), isTrue);
    });

    test('rejects a comment longer than the stored limit', () {
      final tooLong = 'x' * (RatingMath.maxCommentLength + 1);
      expect(RatingMath.isValidComment(tooLong), isFalse);
    });

    test('ignores surrounding whitespace when measuring a comment', () {
      final atLimit = '   ${'x' * RatingMath.maxCommentLength}   ';
      expect(RatingMath.isValidComment(atLimit), isTrue);
    });
  });

  group('RatingMath.roundToTwoDecimals', () {
    test('rounds half up', () {
      expect(RatingMath.roundToTwoDecimals(4.005), 4.01);
      expect(RatingMath.roundToTwoDecimals(3.333333), 3.33);
    });

    test('returns 0 for a non-finite value instead of writing NaN', () {
      expect(RatingMath.roundToTwoDecimals(double.nan), 0);
      expect(RatingMath.roundToTwoDecimals(double.infinity), 0);
    });
  });
}
