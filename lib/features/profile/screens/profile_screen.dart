import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

/// Owner: Profile team (Feature 5)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.editProfile),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.settings),
              child: const Text('Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go(RouteNames.onboarding);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorBright,
                foregroundColor: AppColors.textPrimary,
                textStyle: AppTextStyles.button.copyWith(
                  color: AppColors.textPrimary,
                ),
                shape: const StadiumBorder(),
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
