import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../models/review.dart';
import 'star_rating_display.dart';

/// Renders one review: author, stars, when it was left, and the comment.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final fallbackAvatar = Container(
      width: 40,
      height: 40,
      color: AppColors.tertiaryDark,
      child: const Icon(Icons.person, color: AppColors.textMuted, size: 20),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: review.authorImageUrl.isEmpty
                    ? fallbackAvatar
                    : Image.network(
                        review.authorImageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => fallbackAvatar,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: AppTextStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (review.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        formatRelativeDate(review.createdAt!),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StarRatingDisplay(rating: review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Short, human-readable age of a review ('2 days ago').
///
/// Top-level so it can be unit tested without building a widget.
String formatRelativeDate(DateTime date, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(date);

  if (difference.inDays >= 365) {
    final years = difference.inDays ~/ 365;
    return years == 1 ? 'a year ago' : '$years years ago';
  }
  if (difference.inDays >= 30) {
    final months = difference.inDays ~/ 30;
    return months == 1 ? 'a month ago' : '$months months ago';
  }
  if (difference.inDays >= 1) {
    return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
  }
  if (difference.inHours >= 1) {
    return difference.inHours == 1 ? 'An hour ago' : '${difference.inHours} hours ago';
  }
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} min ago';
  }
  return 'Just now';
}
