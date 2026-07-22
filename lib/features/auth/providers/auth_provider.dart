import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';

export '../../../core/models/app_user.dart' show UserRole;

/// Auth state shared by both clients and tradesmen.
///
/// [selectedRole] is set during onboarding before sign-in. Once Firebase Auth
/// returns a user, [authenticatedUser] is populated and the app routes by role.
class AuthState {
  const AuthState({
    this.selectedRole = UserRole.client,
    this.authenticatedUser,
  });

  final UserRole selectedRole;
  final AppUser? authenticatedUser;

  bool get isAuthenticated => authenticatedUser != null;

  UserRole get currentRole => authenticatedUser?.role ?? selectedRole;

  AuthState copyWith({
    UserRole? selectedRole,
    AppUser? authenticatedUser,
  }) {
    return AuthState(
      selectedRole: selectedRole ?? this.selectedRole,
      authenticatedUser: authenticatedUser ?? this.authenticatedUser,
    );
  }
}

// using Notifier because StateNotifier was removed in Riverpod 3
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void selectRole(UserRole role) =>
      state = state.copyWith(selectedRole: role);

  /// Called after a successful Firebase Auth sign-in.
  void signIn(AppUser user) => state = state.copyWith(
        authenticatedUser: user,
        selectedRole: user.role,
      );

  // TODO: also call firebase signout
  void signOut() => state = const AuthState();
}
