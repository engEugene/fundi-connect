import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

/// Owner: Auth team (Feature 2)
///
/// Replace this mock logic with Firebase Auth calls when the backend is ready.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    // TODO: call Firebase Auth
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(status: AuthStatus.authenticated);
  }

  void signOut() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
