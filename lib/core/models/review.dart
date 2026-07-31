import 'package:cloud_firestore/cloud_firestore.dart';

/// A single review left by a client on a completed booking.
///
/// Maps 1-to-1 with a `reviews/{reviewId}` document. `authorName` and
/// `authorImageUrl` are denormalised copies of the client's `displayName` and
/// `photoUrl` (stored as `clientName` / `clientPhotoUrl` on the document) so a
/// worker's review list renders from one query instead of one extra read per
/// row.
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    this.bookingId = '',
    this.clientId = '',
    this.workerId = '',
    this.authorName = 'Client',
    this.authorImageUrl = '',
    this.createdAt,
  });

  /// Firestore document id.
  final String id;

  /// The completed booking this review is attached to. One review per booking.
  final String bookingId;

  /// Author — the client who was served.
  final String clientId;

  /// Subject — the tradesman being rated.
  final String workerId;

  /// Whole stars, 1 to 5.
  final double rating;

  final String comment;

  /// Denormalised author display fields.
  final String authorName;
  final String authorImageUrl;

  final DateTime? createdAt;

  /// Reads a `reviews/{id}` document.
  ///
  /// `createdAt` can be null for a moment after a write, because the field is
  /// written with [FieldValue.serverTimestamp] and the optimistic local
  /// snapshot arrives before the server fills it in.
  factory Review.fromJson(String id, Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];

    return Review(
      id: id,
      bookingId: json['bookingId'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      workerId: json['workerId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      authorName: json['clientName'] as String? ?? 'Client',
      authorImageUrl: json['clientPhotoUrl'] as String? ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
    );
  }

  /// Serialises for a Firestore write.
  ///
  /// `createdAt` is deliberately excluded — the repository sets it with
  /// [FieldValue.serverTimestamp] so the ordering of reviews cannot be forged
  /// by a device with a wrong clock.
  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'clientId': clientId,
        'workerId': workerId,
        'rating': rating,
        'comment': comment,
        'clientName': authorName,
        'clientPhotoUrl': authorImageUrl,
      };

  Review copyWith({
    String? id,
    String? bookingId,
    String? clientId,
    String? workerId,
    double? rating,
    String? comment,
    String? authorName,
    String? authorImageUrl,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      clientId: clientId ?? this.clientId,
      workerId: workerId ?? this.workerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.bookingId == bookingId &&
        other.clientId == clientId &&
        other.workerId == workerId &&
        other.rating == rating &&
        other.comment == comment &&
        other.authorName == authorName &&
        other.authorImageUrl == authorImageUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        bookingId,
        clientId,
        workerId,
        rating,
        comment,
        authorName,
        authorImageUrl,
        createdAt,
      );
}
