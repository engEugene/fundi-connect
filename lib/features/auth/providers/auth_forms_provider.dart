// autoDispose so forms clear when you leave.
// error overwrites instead of falling back — lets us clear errors
// without extra flags. submit returns result, never navigates from here.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../domain/validators.dart';
import 'auth_provider.dart';
import '../data/auth_repository.dart';
// ─── Sign in ────────────────────────────────────────────────────────────────

class SignInFormState {
  const SignInFormState({
    this.obscurePassword = true,
    this.submitting = false,
    this.error,
  });

  final bool obscurePassword;
  final bool submitting;
  final String? error;

  bool get busy => submitting;

  SignInFormState copyWith({
    bool? obscurePassword,
    bool? submitting,
    String? error,
  }) => SignInFormState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    submitting: submitting ?? this.submitting,
    error: error,
  );
}

final signInFormProvider =
    NotifierProvider.autoDispose<SignInFormNotifier, SignInFormState>(
      SignInFormNotifier.new,
    );

class SignInFormNotifier extends AutoDisposeNotifier<SignInFormState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  SignInFormState build() => const SignInFormState();

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  Future<AppUser?> signInWithEmail(String email, String password) async {
    if (state.busy) return null;
    state = state.copyWith(submitting: true, error: null);

    try {
      final user = await _repository.signInWithEmail(email, password);
      ref.read(authProvider.notifier).signIn(user);
      state = state.copyWith(submitting: false);
      return user;
    } on AuthException catch (e) {
      state = state.copyWith(submitting: false, error: e.message);
      return null;
    } catch (_) {
      state = state.copyWith(
        submitting: false,
        error: 'Something went wrong. Please try again.',
      );
      return null;
    }
  }

}

// ─── Sign up ────────────────────────────────────────────────────────────────

enum SignUpOutcome { success, failed }

class SignUpFormState {
  const SignUpFormState({
    this.obscurePassword = true,
    this.submitting = false,
    this.error,
  });

  final bool obscurePassword;
  final bool submitting;
  final String? error;

  SignUpFormState copyWith({
    bool? obscurePassword,
    bool? submitting,
    String? error,
  }) => SignUpFormState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    submitting: submitting ?? this.submitting,
    error: error,
  );
}

final signUpFormProvider =
    NotifierProvider.autoDispose<SignUpFormNotifier, SignUpFormState>(
      SignUpFormNotifier.new,
    );

class SignUpFormNotifier extends AutoDisposeNotifier<SignUpFormState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  SignUpFormState build() => const SignUpFormState();

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  /// Creates a new account and stores the phone number in the user document.
  Future<SignUpOutcome> submit({
    required String name,
    required String email,
    required String password,
    required String dialCode,
    required String localPhone,
    required UserRole role,
  }) async {
    if (state.submitting) return SignUpOutcome.failed;
    state = state.copyWith(submitting: true, error: null);

    final phone = Validators.toE164(dialCode, localPhone);

    try {
      final user = await _repository.createAccountWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );
      ref.read(authProvider.notifier).signIn(user);

      state = state.copyWith(submitting: false);
      return SignUpOutcome.success;
    } on AuthException catch (e) {
      state = state.copyWith(submitting: false, error: e.message);
      return SignUpOutcome.failed;
    } catch (_) {
      state = state.copyWith(
        submitting: false,
        error: 'Something went wrong. Please try again.',
      );
      return SignUpOutcome.failed;
    }
  }
}

// ─── Verify phone ───────────────────────────────────────────────────────────
// ─── Forgot password ────────────────────────────────────────────────────────

class ForgotPasswordState {
  const ForgotPasswordState({this.submitting = false, this.sentToEmail});

  final bool submitting;
  final String? sentToEmail;

  bool get sent => sentToEmail != null;
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );

class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  // always say success, otherwise people can check if emails exist
  Future<void> sendResetLink(String email) async {
    if (state.submitting) return;
    state = const ForgotPasswordState(submitting: true);

    try {
      await _repository.sendPasswordResetEmail(email);
    } on AuthException catch (_) {
      // Surface only real failures; 'user-not-found' is swallowed by the repo.
    } catch (_) {
      // Network or other errors still show the same success message so callers
      // can't probe for registered emails.
    }

    state = ForgotPasswordState(sentToEmail: email.trim());
  }
}
