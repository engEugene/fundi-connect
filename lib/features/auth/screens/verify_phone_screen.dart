import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../domain/validators.dart';
import '../providers/auth_forms_provider.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_widgets.dart';

// 6 boxes bcs firebase sends 6 digit codes, not 4 like the design
class VerifyPhoneScreen extends ConsumerStatefulWidget {
  const VerifyPhoneScreen({super.key, this.dialCode, this.localPhoneNumber});

  final String? dialCode;
  final String? localPhoneNumber;

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends ConsumerState<VerifyPhoneScreen> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _codeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(verifyPhoneProvider.notifier)
        .verifyCode(_code.text);
    if (!mounted || !ok) return;
    // clear the auth stack after sign-up
    context.go(RouteNames.home);
  }

  Future<void> _resend() async {
    await ref.read(verifyPhoneProvider.notifier).resendCode();
    if (!mounted) return;
    _code.clear();
    _codeFocus.requestFocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('A new code is on its way.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyPhoneProvider);
    final phone = widget.localPhoneNumber;
    final label = phone == null
        ? 'your phone'
        : Validators.maskPhone(
            widget.dialCode ?? Validators.defaultDialCode,
            phone,
          );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AuthStyles.pagePadding.copyWith(top: 16, bottom: 32),
          children: [
            const AuthHeader(title: 'Verify Phone'),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smartphone_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Enter Verification Code',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a ${Validators.otpLength}-digit code to',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            OtpInput(
              controller: _code,
              focusNode: _codeFocus,
              length: Validators.otpLength,
              hasError: state.error != null,
              enabled: !state.submitting,
              onCompleted: (_) => _verify(),
            ),
            const SizedBox(height: 20),
            _ExpiryRow(state: state),
            const SizedBox(height: 24),
            FormErrorBanner(message: state.error),
            AuthSubmitButton(
              label: 'Verify Code',
              loading: state.submitting,
              enabled: !state.resending,
              onPressed: _verify,
            ),
            const SizedBox(height: 8),
            AuthFooterPrompt(
              question: "Didn't receive a code?",
              actionLabel: state.resending ? 'Sending…' : 'Resend',
              // can't resend till timer's up, firebase charges per sms
              onPressed: state.canResend ? _resend : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  const _ExpiryRow({required this.state});

  final VerifyPhoneState state;

  @override
  Widget build(BuildContext context) {
    final expired = state.expired;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          expired ? Icons.timer_off_outlined : Icons.access_time_rounded,
          size: 18,
          color: expired ? AppColors.error : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            text: expired ? 'Code expired' : 'Code expires in ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: expired ? AppColors.error : AppColors.primaryLight,
            ),
            children: [
              if (!expired)
                TextSpan(
                  text: state.countdownLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
