import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

/// Read-only row of stars.
///
/// Lives in `core/widgets/` because three different features render it
/// (worker cards, worker detail, review cards) and it carries no business
/// logic — the interactive picker lives with the reviews feature instead.
class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.starSize = 16,
    this.starCount = 5,
  });

  final double rating;
  final double starSize;
  final int starCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of $starCount stars',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(starCount, (index) {
          return Icon(
            index < rating.round()
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: starSize,
            color: AppColors.secondary,
          );
        }),
      ),
    );
  }
}
