import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/verify_email_provider.dart';
import '../widgets/auth_widgets.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifyEmailProvider);
    final notifier = ref.read(verifyEmailProvider.notifier);
    final email = state.email ??
        ref.watch(authProvider.select((s) => s.authenticatedUser?.email));

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AuthStyles.pagePadding.copyWith(top: 16, bottom: 32),
          children: [
            const AuthHeader(
              title: 'Verify your email',
              subtitle: 'We sent a link to your inbox. Tap it to continue.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Check your email',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                text: 'We sent a verification link to ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: email ?? 'your email address',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: '. Tap the link in the email to verify your account.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (state.error != null)
              FormErrorBanner(message: state.error)
            else
              const SizedBox(height: 64),
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: state.checking ? 'Checking...' : 'I verified my email',
              loading: state.checking,
              onPressed: () async {
                final verified = await notifier.checkVerification();
                if (!context.mounted) return;
                if (verified) {
                  context.go(RouteNames.home);
                }
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: state.canResend ? notifier.resend : null,
                child: Text(
                  state.sending
                      ? 'Sending...'
                      : state.resentCooldownSeconds > 0
                          ? 'Resend in ${state.resentCooldownSeconds}s'
                          : 'Resend email',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: state.canResend
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
