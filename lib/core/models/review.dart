class Review {
  const Review({
    required this.id,
    required this.authorName,
    required this.authorImageUrl,
    required this.rating,
    required this.comment,
  });

  /// `clientName`/`clientPhotoUrl` must be denormalised onto the review doc —
  /// the schema in ARCHITECTURE.md §8 only lists `clientId`.
  factory Review.fromJson(String id, Map<String, dynamic> json) => Review(
        id: id,
        authorName: json['clientName'] as String? ?? 'Client',
        authorImageUrl: json['clientPhotoUrl'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        comment: json['comment'] as String? ?? '',
      );

  final String id;
  final String authorName;
  final String authorImageUrl;
  final double rating;
  final String comment;

  static const List<Review> sample = [
    Review(
      id: 'r1',
      authorName: 'Amina U.',
      authorImageUrl: 'https://i.pravatar.cc/300?img=5',
      rating: 5,
      comment: 'Very professional and quick. Fixed my wiring in 2 hours!',
    ),
    Review(
      id: 'r2',
      authorName: 'David K.',
      authorImageUrl: 'https://i.pravatar.cc/300?img=3',
      rating: 4,
      comment: 'Reliable and affordable. Will book again.',
    ),
    Review(
      id: 'r3',
      authorName: 'Marie C.',
      authorImageUrl: 'https://i.pravatar.cc/300?img=9',
      rating: 5,
      comment: 'Excellent work, arrived on time and cleaned up after.',
    ),
  ];
}
