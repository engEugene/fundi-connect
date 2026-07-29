import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../domain/validators.dart';
import '../providers/auth_forms_provider.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_widgets.dart';

// wasn't in the design, added so people who forget passwords don't get stuck
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(forgotPasswordProvider.notifier).sendResetLink(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AuthStyles.pagePadding.copyWith(top: 16, bottom: 32),
          children: [
            const AuthHeader(title: 'Forgot Password'),
            const SizedBox(height: 32),
            if (state.sent)
              _SentPanel(email: state.sentToEmail!, onDone: context.pop)
            else
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter the email address on your account and we will '
                      'send you a link to reset your password.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthTextField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      icon: Icons.mail_outline,
                      controller: _email,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      enabled: !state.submitting,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 28),
                    AuthSubmitButton(
                      label: 'Send Reset Link',
                      loading: state.submitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// says "if account exists" bcs we can't tell (and shouldn't)
class _SentPanel extends StatelessWidget {
  const _SentPanel({required this.email, required this.onDone});

  final String email;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 40,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'If an account exists for ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            children: [
              TextSpan(
                text: email,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text:
                    ', a reset link is on its way. Check your spam folder if '
                    'it does not arrive within a few minutes.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AuthSubmitButton(label: 'Back to Sign In', onPressed: onDone),
      ],
    );
  }
}
