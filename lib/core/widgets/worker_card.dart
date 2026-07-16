import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../models/worker.dart';
import '../utils/formatters.dart';

class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.worker,
    this.onTap,
  });

  final Worker worker;
  final VoidCallback? onTap;

  String get _formattedPrice =>
      '${Formatters.formatNumber(worker.hourlyRate)} Rwf/hr';

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(imageUrl: worker.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (worker.isVerified) ...[
                          const Icon(
                            Icons.verified,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            worker.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (worker.isOpen)
                          Text(
                            'Open',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      worker.role,
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: AppColors.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.rating}',
                          style: AppTextStyles.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${worker.reviewCount})',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          color: AppColors.textMuted,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${worker.distanceKm} km',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formattedPrice,
                style: AppTextStyles.price,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 56,
          color: AppColors.tertiary,
          child: const Icon(
            Icons.person,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
