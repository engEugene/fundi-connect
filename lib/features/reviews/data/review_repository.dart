import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/booking.dart';
import '../../../core/models/review.dart';
import '../../../core/services/firestore_service.dart';
import '../domain/rating_math.dart';

/// Thrown when a review cannot be written. Carries a message that is safe to
/// show directly in a SnackBar.
class ReviewException implements Exception {
  const ReviewException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The only place that talks to the `reviews` collection.
///
/// Writing a review touches three documents that must stay consistent with each
/// other:
///
///   1. `reviews/{reviewId}`   — the new review
///   2. `workers/{workerId}`   — `ratingAvg` and `reviewCount` recomputed
///   3. `bookings/{bookingId}` — `isRated: true` and a back-pointer `reviewId`
///
/// They are written in a single [FirebaseFirestore.runTransaction] so a crash
/// or a lost connection can never leave a worker with a rating that counts a
/// review that does not exist, or a booking that offers "Rate" twice. This is
/// the client-side alternative to a Cloud Function trigger, which the team
/// ruled out for the MVP (ARCHITECTURE.md §12).
class ReviewRepository {
  ReviewRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? const FirestoreService();

  final FirestoreService _firestore;

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------

  /// Submits a review for a completed booking and returns the new review id.
  ///
  /// Validates locally first (fast feedback, no wasted round trip), then
  /// re-validates inside the transaction against the *server's* copy of the
  /// booking — a client cannot rate someone else's booking, rate a job that is
  /// not finished, or rate the same booking twice, even if it replays the call.
  /// `firestore.rules` enforces the same conditions a third time for a caller
  /// that bypasses the app entirely.
  Future<String> submitReview({
    required String bookingId,
    required String clientId,
    required int rating,
    required String comment,
    String clientName = 'Client',
    String clientPhotoUrl = '',
  }) async {
    if (!RatingMath.isValidRating(rating)) {
      throw const ReviewException('Please choose a rating from 1 to 5 stars.');
    }
    if (!RatingMath.isValidComment(comment)) {
      throw const ReviewException(
        'Your comment is too long. Please keep it under '
        '${RatingMath.maxCommentLength} characters.',
      );
    }

    final trimmedComment = comment.trim();
    final bookingRef = _firestore.bookingDoc(bookingId);
    final reviewRef = _firestore.reviews.doc();

    try {
      await _firestore.runTransaction<void>((transaction) async {
        // --- All reads must happen before any write in a Firestore
        // --- transaction, so both documents are fetched up front.
        final bookingSnapshot = await transaction.get(bookingRef);
        final bookingData = bookingSnapshot.data();

        if (!bookingSnapshot.exists || bookingData == null) {
          throw const ReviewException('This booking no longer exists.');
        }

        final workerId = bookingData['workerId'] as String? ?? '';
        if (workerId.isEmpty) {
          throw const ReviewException(
            'This booking has no tradesman attached to it.',
          );
        }

        final workerRef = _firestore.workerDoc(workerId);
        final workerSnapshot = await transaction.get(workerRef);

        // --- Server-side guards -------------------------------------------
        if (bookingData['clientId'] != clientId) {
          throw const ReviewException('You can only review your own bookings.');
        }
        if (bookingData['status'] != BookingLifecycle.completed) {
          throw const ReviewException(
            'You can only review a job once it is completed.',
          );
        }
        if (bookingData['isRated'] == true) {
          throw const ReviewException('You have already reviewed this booking.');
        }

        // --- Writes --------------------------------------------------------
        final review = Review(
          id: reviewRef.id,
          bookingId: bookingId,
          clientId: clientId,
          workerId: workerId,
          rating: rating.toDouble(),
          comment: trimmedComment,
          authorName: clientName,
          authorImageUrl: clientPhotoUrl,
        );

        transaction.set(reviewRef, {
          ...review.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Recompute the worker's denormalised aggregate from its current value
        // rather than counting review documents, so this stays O(1).
        final workerData = workerSnapshot.data();
        final aggregate = RatingMath.applyNewRating(
          currentAverage: (workerData?['ratingAvg'] as num?)?.toDouble() ?? 0,
          currentCount: (workerData?['reviewCount'] as num?)?.toInt() ?? 0,
          rating: rating,
        );

        // `set` with merge rather than `update`: a worker document created
        // before these fields existed would make `update` fail.
        transaction.set(
          workerRef,
          {
            'ratingAvg': aggregate.average,
            'reviewCount': aggregate.count,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.update(bookingRef, {
          'isRated': true,
          'reviewId': reviewRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on ReviewException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ReviewException(_mapFirestoreError(e));
    }

    return reviewRef.id;
  }

  // ---------------------------------------------------------------------------
  // READ
  // ---------------------------------------------------------------------------

  /// Live stream of every review a tradesman has received, newest first.
  ///
  /// Needs the `reviews (workerId ASC, createdAt DESC)` composite index.
  Stream<List<Review>> watchWorkerReviews(String workerId, {int? limit}) {
    Query<Map<String, dynamic>> query = _firestore.reviews
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(_toReviews);
  }

  /// Live stream of every review a client has written, newest first.
  ///
  /// Needs the `reviews (clientId ASC, createdAt DESC)` composite index.
  Stream<List<Review>> watchClientReviews(String clientId) {
    return _firestore.reviews
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toReviews);
  }

  /// The review attached to a booking, or null if it has not been rated yet.
  /// Used to switch the booking detail screen between "Rate Worker" and a
  /// read-only copy of what the client already said.
  Stream<Review?> watchReviewForBooking(String bookingId) {
    return _firestore.reviews
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return Review.fromJson(doc.id, doc.data());
    });
  }

  /// One-shot read of a worker's reviews, for tests and for the report's
  /// screenshots where a stream is not needed.
  Future<List<Review>> fetchWorkerReviews(String workerId) async {
    final snapshot = await _firestore.reviews
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();
    return _toReviews(snapshot);
  }

  List<Review> _toReviews(QuerySnapshot<Map<String, dynamic>> snapshot) =>
      snapshot.docs.map((doc) => Review.fromJson(doc.id, doc.data())).toList();

  /// Turns Firestore error codes into wording a client can act on.
  String _mapFirestoreError(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        'You do not have permission to review this booking.',
      'not-found' => 'This booking no longer exists.',
      'unavailable' =>
        'No connection. Check your network and try again.',
      'failed-precondition' =>
        'Could not save your review right now. Please try again.',
      _ => e.message ?? 'Could not save your review. Please try again.',
    };
  }
}
