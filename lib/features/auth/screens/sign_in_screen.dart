import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../domain/validators.dart';
import '../providers/auth_forms_provider.dart';
import '../widgets/auth_fields.dart';
import '../widgets/auth_widgets.dart';

// StatefulWidget only to clean up controllers, no setState used
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(signInFormProvider.notifier)
        .signInWithEmail(_email.text.trim(), _password.text);

    if (!mounted || !ok) return;
    // go to clear the auth stack
    context.go(RouteNames.home);
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    final ok = await ref.read(signInFormProvider.notifier).signInWithGoogle();
    if (!mounted || !ok) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signInFormProvider);
    final notifier = ref.read(signInFormProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: ListView(
              padding: AuthStyles.pagePadding.copyWith(top: 16, bottom: 32),
              children: [
                const AuthHeader(
                  title: 'Welcome back',
                  subtitle: 'Sign in to continue to Fundi Connect',
                ),
                const SizedBox(height: 32),
                FormErrorBanner(message: form.error),
                AuthTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  icon: Icons.mail_outline,
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  enabled: !form.busy,
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
                const SizedBox(height: 20),
                AuthTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  controller: _password,
                  focusNode: _passwordFocus,
                  validator: Validators.signInPassword,
                  obscureText: form.obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !form.busy,
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: PasswordVisibilityToggle(
                    obscured: form.obscurePassword,
                    onPressed: notifier.togglePasswordVisibility,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: form.busy
                        ? null
                        : () => context.push(RouteNames.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 12),
                AuthSubmitButton(
                  label: 'Sign In',
                  loading: form.submitting,
                  enabled: !form.googleSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                const OrDivider(),
                const SizedBox(height: 24),
                GoogleSignInButton(
                  loading: form.googleSubmitting,
                  enabled: !form.submitting,
                  onPressed: _google,
                ),
                const SizedBox(height: 8),
                AuthFooterPrompt(
                  question: "Don't have an account?",
                  actionLabel: 'Create Account',
                  onPressed: form.busy
                      ? null
                      : () => context.push(RouteNames.createAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
