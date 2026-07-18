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

// back arrow goes to role select, not onboarding
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountState();
}

class _CreateAccountState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _dialCode = TextEditingController(text: Validators.defaultDialCode);
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _dialCode.dispose();
    _phone.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final outcome = await ref.read(signUpFormProvider.notifier).submit();

    if (!mounted) return;
    switch (outcome) {
      case SignUpOutcome.awaitingOtp:
        // using query params not extra so deep links work too
        context.push(
          '${RouteNames.verifyPhone}'
          '?dial=${Uri.encodeComponent(_dialCode.text)}'
          '&phone=${Uri.encodeComponent(_phone.text)}',
        );
      case SignUpOutcome.completed:
        context.go(RouteNames.home);
      case SignUpOutcome.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signUpFormProvider);
    final notifier = ref.read(signUpFormProvider.notifier);
    final busy = form.submitting;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: AuthStyles.pagePadding.copyWith(top: 16, bottom: 32),
              children: [
                const AuthHeader(
                  title: 'Create Account',
                  subtitle: 'Join thousands of clients and workers in Rwanda',
                ),
                const SizedBox(height: 28),
                FormErrorBanner(message: form.error),
                AuthTextField(
                  label: 'Full Name',
                  hint: 'e.g. Amina Uwase',
                  icon: Icons.person_outline,
                  controller: _name,
                  validator: Validators.fullName,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  enabled: !busy,
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !busy,
                ),
                const SizedBox(height: 20),
                PhoneNumberField(
                  dialCodeController: _dialCode,
                  numberController: _phone,
                  enabled: !busy,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Password',
                  hint: 'Create a strong password',
                  icon: Icons.lock_outline,
                  controller: _password,
                  focusNode: _passwordFocus,
                  validator: Validators.password,
                  obscureText: form.obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !busy,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: PasswordVisibilityToggle(
                    obscured: form.obscurePassword,
                    onPressed: notifier.togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'At least ${Validators.minPasswordLength} characters, '
                  'including a letter and a number.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                _OtpToggle(
                  value: form.verifyViaOtp,
                  enabled: !busy,
                  onChanged: notifier.setVerifyViaOtp,
                ),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Create Account',
                  loading: busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                AuthFooterPrompt(
                  question: 'Already have an account?',
                  actionLabel: 'Sign In',
                  onPressed: busy
                      ? null
                      : () => context.push(RouteNames.signIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpToggle extends StatelessWidget {
  const _OtpToggle({
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verify via OTP', style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Send code to your phone',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
