import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/models/category.dart';
import '../../../core/models/worker.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/worker_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const _GreetingHeader(),
              const SizedBox(height: 24),
              const _SpecialOfferCard(),
              const SizedBox(height: 24),
              const _SearchBar(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Categories',
                actionText: 'See all',
                onActionTap: () => context.go(RouteNames.discover),
              ),
              const SizedBox(height: 16),
              const _CategoriesList(),
              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Nearby Tradesmen',
                actionText: 'View all',
                onActionTap: () => context.go(RouteNames.discover),
              ),
              const SizedBox(height: 16),
              _NearbyTradesmenList(
                onWorkerTap: (worker) => context.push(
                  '/worker/${worker.id}',
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Amina Uwase',
                style: AppTextStyles.headlineSmall,
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.tertiary,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecialOfferCard extends StatelessWidget {
  const _SpecialOfferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Special Offer',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'First booking\n20% off!',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.onPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => context.push(RouteNames.confirmBooking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.onSecondary,
                        ),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://i.pravatar.cc/300?img=12',
                width: 110,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 140,
                  color: AppColors.primaryLight,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.onPrimary,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(
            Icons.search,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => context.go(RouteNames.discover),
              style: AppTextStyles.bodyMedium,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                hintText: 'What service do you need?',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go(RouteNames.discover),
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: AppColors.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onActionTap,
  });

  final String title;
  final String actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium,
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionText,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: Category.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (_, index) {
          final category = Category.all[index];
          final isSelected = category.name == 'Electrician';
          return CategoryChip(
            name: category.name,
            icon: category.icon,
            isSelected: isSelected,
            onTap: () => context.go(RouteNames.discover),
          );
        },
      ),
    );
  }
}

class _NearbyTradesmenList extends StatelessWidget {
  const _NearbyTradesmenList({required this.onWorkerTap});

  final ValueChanged<Worker> onWorkerTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: Worker.nearby
          .map(
            (worker) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WorkerCard(
                worker: worker,
                onTap: () => onWorkerTap(worker),
              ),
            ),
          )
          .toList(),
    );
  }
}
