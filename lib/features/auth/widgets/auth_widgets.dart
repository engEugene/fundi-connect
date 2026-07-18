// pill shapes only for auth screens, other features use diff rounding
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';

class AuthStyles {
  AuthStyles._();

  static const double radius = 28;
  static const double fieldHeight = 56;
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24);

  static OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );

  static InputDecorationTheme get inputTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: _border(Colors.transparent),
    enabledBorder: _border(Colors.transparent),
    focusedBorder: _border(AppColors.primary, 1.5),
    errorBorder: _border(AppColors.error),
    focusedErrorBorder: _border(AppColors.error, 1.5),
    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
  );

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
    disabledForegroundColor: AppColors.onPrimary.withValues(alpha: 0.8),
    textStyle: AppTextStyles.button,
    minimumSize: const Size.fromHeight(fieldHeight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    elevation: 0,
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    side: const BorderSide(color: AppColors.inputBorder),
    textStyle: AppTextStyles.labelLarge,
    minimumSize: const Size.fromHeight(fieldHeight),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
  );

  static ButtonStyle get linkButton => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    minimumSize: const Size(0, 48),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (context.canPop()) ...[
              Semantics(
                button: true,
                label: 'Back',
                child: InkWell(
                  onTap: context.pop,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryLight,
            ),
          ),
        ],
      ],
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: AuthStyles.primaryButton,
      onPressed: (loading || !enabled) ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : Text(label),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final VoidCallback onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: AuthStyles.secondaryButton,
      onPressed: (loading || !enabled) ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Text('Continue with Google', style: AppTextStyles.labelLarge),
              ],
            ),
    );
  }
}

class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onPressed,
  });

  final String question;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          style: AuthStyles.linkButton,
          child: Text(
            actionLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class FormErrorBanner extends StatelessWidget {
  const FormErrorBanner({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final message = this.message;
    if (message == null) return const SizedBox.shrink();

    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, size: 20, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
