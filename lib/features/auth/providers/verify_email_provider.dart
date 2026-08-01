import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import '../data/auth_repository.dart';

class VerifyEmailState {
  const VerifyEmailState({
    this.sending = false,
    this.checking = false,
    this.email,
    this.error,
    this.resentCooldownSeconds = 0,
  });

  final bool sending;
  final bool checking;
  final String? email;
  final String? error;
  final int resentCooldownSeconds;

  bool get busy => sending || checking;
  bool get canResend => !busy && resentCooldownSeconds <= 0;

  VerifyEmailState copyWith({
    bool? sending,
    bool? checking,
    String? email,
    String? error,
    int? resentCooldownSeconds,
  }) => VerifyEmailState(
    sending: sending ?? this.sending,
    checking: checking ?? this.checking,
    email: email ?? this.email,
    error: error,
    resentCooldownSeconds: resentCooldownSeconds ?? this.resentCooldownSeconds,
  );
}

final verifyEmailProvider =
    NotifierProvider.autoDispose<VerifyEmailNotifier, VerifyEmailState>(
      VerifyEmailNotifier.new,
    );

class VerifyEmailNotifier extends AutoDisposeNotifier<VerifyEmailState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Timer? _cooldownTimer;
  static const int _cooldownSeconds = 60;

  bool _disposed = false;

  bool get _isActive => !_disposed;

  @override
  VerifyEmailState build() {
    ref.onDispose(() => _disposed = true);
    final user = ref.read(authProvider).authenticatedUser;
    ref.onDispose(() => _cooldownTimer?.cancel());
    _sendInitialEmail();
    return VerifyEmailState(email: user?.email);
  }

  Future<void> _sendInitialEmail() async {
    final user = ref.read(authProvider).authenticatedUser;
    if (user == null || user.emailVerified) return;
    await _sendEmail();
  }

  Future<void> resend() async {
    if (state.busy || !state.canResend) return;
    await _sendEmail();
  }

  Future<void> _sendEmail() async {
    if (!_isActive) return;
    state = state.copyWith(sending: true, error: null);
    try {
      await _repository.sendEmailVerification();
      if (!_isActive) return;
      state = state.copyWith(
        sending: false,
        resentCooldownSeconds: _cooldownSeconds,
      );
      _startCooldown();
    } on AuthException catch (e) {
      if (!_isActive) return;
      state = state.copyWith(sending: false, error: e.message);
    } catch (_) {
      if (!_isActive) return;
      state = state.copyWith(
        sending: false,
        error: 'Could not send verification email. Please try again.',
      );
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resentCooldownSeconds - 1;
      if (next <= 0) timer.cancel();
      state = state.copyWith(resentCooldownSeconds: next < 0 ? 0 : next);
    });
  }

  Future<bool> checkVerification() async {
    if (state.checking) return false;
    state = state.copyWith(checking: true, error: null);

    try {
      final user = await _repository.reloadEmailVerificationStatus();
      if (!_isActive) return false;
      state = state.copyWith(checking: false);
      if (user == null) return false;

      ref.read(authProvider.notifier).signIn(user);
      return user.emailVerified;
    } on AuthException catch (e) {
      if (!_isActive) return false;
      state = state.copyWith(checking: false, error: e.message);
      return false;
    } catch (_) {
      if (!_isActive) return false;
      state = state.copyWith(
        checking: false,
        error: 'Could not check verification status. Please try again.',
      );
      return false;
    }
  }
}
