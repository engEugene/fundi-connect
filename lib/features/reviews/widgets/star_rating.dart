import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../domain/rating_math.dart';

/// Tappable 1-5 star picker.
///
/// Stateless on purpose: the selected value lives in `reviewFormProvider`, so
/// this widget only renders what it is given and reports taps back up.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.starSize = 40,
    this.enabled = true,
  });

  /// Currently selected star count. 0 means nothing selected yet.
  final int value;
  final ValueChanged<int> onChanged;
  final double starSize;
  final bool enabled;

  /// Wording shown under the stars, so the rating is not colour-only —
  /// this is what makes the control readable to a screen reader and to anyone
  /// who cannot distinguish the filled and outlined star shapes.
  static String labelFor(int rating) {
    return switch (rating) {
      1 => 'Poor',
      2 => 'Fair',
      3 => 'Good',
      4 => 'Very good',
      5 => 'Excellent',
      _ => 'Tap a star to rate',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(RatingMath.maxRating, (index) {
            final star = index + 1;
            final isFilled = star <= value;

            return Semantics(
              button: true,
              selected: isFilled,
              label: '$star star${star == 1 ? '' : 's'}',
              child: InkResponse(
                onTap: enabled ? () => onChanged(star) : null,
                radius: starSize * 0.7,
                // 48dp minimum so every star meets the Material tap target.
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    size: starSize,
                    color: isFilled ? AppColors.secondary : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          labelFor(value),
          style: AppTextStyles.bodyMedium.copyWith(
            color: value == 0 ? AppColors.textMuted : AppColors.textPrimary,
            fontWeight: value == 0 ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
