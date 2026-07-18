// autoDispose so forms clear when you leave.
// error overwrites instead of falling back — lets us clear errors
// without extra flags. submit returns result, never navigates from here.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/validators.dart';

// ─── Sign in ────────────────────────────────────────────────────────────────

class SignInFormState {
  const SignInFormState({
    this.obscurePassword = true,
    this.submitting = false,
    this.googleSubmitting = false,
    this.error,
  });

  final bool obscurePassword;
  final bool submitting;
  final bool googleSubmitting;
  final String? error;

  bool get busy => submitting || googleSubmitting;

  SignInFormState copyWith({
    bool? obscurePassword,
    bool? submitting,
    bool? googleSubmitting,
    String? error,
  }) => SignInFormState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    submitting: submitting ?? this.submitting,
    googleSubmitting: googleSubmitting ?? this.googleSubmitting,
    error: error,
  );
}

final signInFormProvider =
    NotifierProvider.autoDispose<SignInFormNotifier, SignInFormState>(
      SignInFormNotifier.new,
    );

class SignInFormNotifier extends AutoDisposeNotifier<SignInFormState> {
  @override
  SignInFormState build() => const SignInFormState();

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  Future<bool> signInWithEmail(String email, String password) async {
    if (state.busy) return false;
    state = state.copyWith(submitting: true);

    // TODO(auth-backend): signInWithEmailAndPassword; map 'user-not-found',
    // 'wrong-password' and 'too-many-requests' onto `error` instead of
    // succeeding.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = state.copyWith(submitting: false);
    return true;
  }

  Future<bool> signInWithGoogle() async {
    if (state.busy) return false;
    state = state.copyWith(googleSubmitting: true);

    // TODO(auth-backend): GoogleSignIn + signInWithCredential. A cancelled
    // account picker is a no-op, not an error.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = state.copyWith(googleSubmitting: false);
    return true;
  }
}

// ─── Sign up ────────────────────────────────────────────────────────────────

enum SignUpOutcome { awaitingOtp, completed, failed }

class SignUpFormState {
  const SignUpFormState({
    this.obscurePassword = true,
    this.verifyViaOtp = true,
    this.submitting = false,
    this.error,
  });

  final bool obscurePassword;

  // on by default so workers can get the verified badge
  final bool verifyViaOtp;
  final bool submitting;
  final String? error;

  SignUpFormState copyWith({
    bool? obscurePassword,
    bool? verifyViaOtp,
    bool? submitting,
    String? error,
  }) => SignUpFormState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    verifyViaOtp: verifyViaOtp ?? this.verifyViaOtp,
    submitting: submitting ?? this.submitting,
    error: error,
  );
}

final signUpFormProvider =
    NotifierProvider.autoDispose<SignUpFormNotifier, SignUpFormState>(
      SignUpFormNotifier.new,
    );

class SignUpFormNotifier extends AutoDisposeNotifier<SignUpFormState> {
  @override
  SignUpFormState build() => const SignUpFormState();

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void setVerifyViaOtp(bool value) =>
      state = state.copyWith(verifyViaOtp: value);

  Future<SignUpOutcome> submit() async {
    if (state.submitting) return SignUpOutcome.failed;
    state = state.copyWith(submitting: true);

    // TODO(auth-backend): createUserWithEmailAndPassword, updateDisplayName,
    // then write users/{uid} with the role chosen on Role Select.
    // 'email-already-in-use' and 'weak-password' surface through `error`.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = state.copyWith(submitting: false);
    return state.verifyViaOtp
        ? SignUpOutcome.awaitingOtp
        : SignUpOutcome.completed;
  }
}

// ─── Verify phone ───────────────────────────────────────────────────────────

class VerifyPhoneState {
  const VerifyPhoneState({
    this.secondsRemaining = codeLifetimeSeconds,
    this.submitting = false,
    this.resending = false,
    this.error,
    this.verificationId,
  });

  // firebase don't tell us real expiry so we made our own countdown,
  // also doubles as the resend cooldown
  static const int codeLifetimeSeconds = 120;

  final int secondsRemaining;
  final bool submitting;
  final bool resending;
  final String? error;

  // comes from firebase's codeSent callback, needed for PhoneAuthCredential
  final String? verificationId;

  bool get expired => secondsRemaining <= 0;
  bool get canResend => expired && !resending && !submitting;

  String get countdownLabel =>
      '${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:'
      '${(secondsRemaining % 60).toString().padLeft(2, '0')}';

  VerifyPhoneState copyWith({
    int? secondsRemaining,
    bool? submitting,
    bool? resending,
    String? error,
    String? verificationId,
  }) => VerifyPhoneState(
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    submitting: submitting ?? this.submitting,
    resending: resending ?? this.resending,
    error: error,
    verificationId: verificationId ?? this.verificationId,
  );
}

final verifyPhoneProvider =
    NotifierProvider.autoDispose<VerifyPhoneNotifier, VerifyPhoneState>(
      VerifyPhoneNotifier.new,
    );

class VerifyPhoneNotifier extends AutoDisposeNotifier<VerifyPhoneState> {
  Timer? _timer;

  @override
  VerifyPhoneState build() {
    // cancel timer or it'll write to a dead provider after we leave
    ref.onDispose(() => _timer?.cancel());
    _startCountdown();
    return const VerifyPhoneState();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsRemaining - 1;
      if (next <= 0) timer.cancel();
      state = state.copyWith(
        secondsRemaining: next < 0 ? 0 : next,
        error: state.error,
      );
    });
  }

  Future<bool> verifyCode(String code) async {
    if (state.submitting) return false;

    final invalid = Validators.otp(code);
    if (invalid != null) {
      state = state.copyWith(error: invalid);
      return false;
    }
    if (state.expired) {
      state = state.copyWith(
        error: 'That code has expired. Request a new one.',
      );
      return false;
    }

    state = state.copyWith(submitting: true);

    // TODO(auth-backend): build a PhoneAuthCredential from verificationId +
    // code and link it to the current user. 'invalid-verification-code' and
    // 'session-expired' are worth messaging separately.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = state.copyWith(submitting: false);
    return true;
  }

  Future<void> resendCode() async {
    if (!state.canResend) return;
    state = state.copyWith(resending: true);

    // TODO(auth-backend): call verifyPhoneNumber again with the stored
    // forceResendingToken, or Firebase reuses the first session.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    state = state.copyWith(
      resending: false,
      secondsRemaining: VerifyPhoneState.codeLifetimeSeconds,
    );
    _startCountdown();
  }
}

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
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  // always say success, otherwise people can check if emails exist
  Future<void> sendResetLink(String email) async {
    if (state.submitting) return;
    state = const ForgotPasswordState(submitting: true);

    // TODO(auth-backend): sendPasswordResetEmail; swallow 'user-not-found',
    // surface only real failures like 'network-request-failed'.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    state = ForgotPasswordState(sentToEmail: email.trim());
  }
}
