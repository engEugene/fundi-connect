import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fundi_connect/core/models/review.dart';
import 'package:fundi_connect/core/widgets/review_card.dart';

/// Unit tests for the [Review] model's Firestore mapping.
void main() {
  group('Review.fromJson', () {
    test('maps a full review document', () {
      final createdAt = DateTime.utc(2026, 5, 20, 9, 30);

      final review = Review.fromJson('review123', {
        'bookingId': 'booking123',
        'clientId': 'client-uid',
        'workerId': 'worker-uid',
        'rating': 5,
        'comment': 'Very professional and quick.',
        'clientName': 'Amina Uwase',
        'clientPhotoUrl': 'https://example.com/amina.jpg',
        'createdAt': Timestamp.fromDate(createdAt),
      });

      expect(review.id, 'review123');
      expect(review.bookingId, 'booking123');
      expect(review.clientId, 'client-uid');
      expect(review.workerId, 'worker-uid');
      expect(review.rating, 5.0);
      expect(review.comment, 'Very professional and quick.');
      expect(review.authorName, 'Amina Uwase');
      expect(review.authorImageUrl, 'https://example.com/amina.jpg');
      expect(review.createdAt, createdAt);
    });

    test('survives a document written before optional fields existed', () {
      final review = Review.fromJson('r1', const {
        'workerId': 'worker-uid',
        'rating': 4,
      });

      expect(review.comment, isEmpty);
      expect(review.authorName, 'Client');
      expect(review.authorImageUrl, isEmpty);
      expect(review.createdAt, isNull);
    });

    test('leaves createdAt null while the server timestamp is still pending',
        () {
      // The optimistic local snapshot arrives with createdAt unset.
      final review = Review.fromJson('r1', const {
        'workerId': 'worker-uid',
        'rating': 5,
        'createdAt': null,
      });

      expect(review.createdAt, isNull);
    });

    test('reads an integer rating as a double', () {
      final review = Review.fromJson('r1', const {'rating': 3});
      expect(review.rating, isA<double>());
      expect(review.rating, 3.0);
    });
  });

  group('Review.toJson', () {
    test('writes the field names the Firestore schema and rules expect', () {
      const review = Review(
        id: 'r1',
        bookingId: 'b1',
        clientId: 'c1',
        workerId: 'w1',
        rating: 4,
        comment: 'Good work.',
        authorName: 'Amina',
        authorImageUrl: 'https://example.com/a.jpg',
      );

      final json = review.toJson();

      expect(json['bookingId'], 'b1');
      expect(json['clientId'], 'c1');
      expect(json['workerId'], 'w1');
      expect(json['rating'], 4);
      expect(json['comment'], 'Good work.');
      // Author fields are denormalised under their document names.
      expect(json['clientName'], 'Amina');
      expect(json['clientPhotoUrl'], 'https://example.com/a.jpg');
    });

    test('omits createdAt so the repository can set a server timestamp', () {
      const review = Review(id: 'r1', rating: 5, comment: '');
      expect(review.toJson().containsKey('createdAt'), isFalse);
    });

    test('round-trips through Firestore without losing data', () {
      const original = Review(
        id: 'r1',
        bookingId: 'b1',
        clientId: 'c1',
        workerId: 'w1',
        rating: 5,
        comment: 'Excellent.',
        authorName: 'David K.',
        authorImageUrl: 'https://example.com/d.jpg',
      );

      final restored = Review.fromJson('r1', original.toJson());

      expect(restored, original);
    });
  });

  group('formatRelativeDate', () {
    final now = DateTime.utc(2026, 6, 1, 12, 0);

    test('describes a review left moments ago', () {
      expect(
        formatRelativeDate(now.subtract(const Duration(seconds: 20)), now: now),
        'Just now',
      );
    });

    test('describes minutes, hours and days', () {
      expect(
        formatRelativeDate(now.subtract(const Duration(minutes: 5)), now: now),
        '5 min ago',
      );
      expect(
        formatRelativeDate(now.subtract(const Duration(hours: 3)), now: now),
        '3 hours ago',
      );
      expect(
        formatRelativeDate(now.subtract(const Duration(days: 1)), now: now),
        'Yesterday',
      );
      expect(
        formatRelativeDate(now.subtract(const Duration(days: 4)), now: now),
        '4 days ago',
      );
    });

    test('falls back to months and years for older reviews', () {
      expect(
        formatRelativeDate(now.subtract(const Duration(days: 45)), now: now),
        'a month ago',
      );
      expect(
        formatRelativeDate(now.subtract(const Duration(days: 400)), now: now),
        'a year ago',
      );
    });
  });
}
