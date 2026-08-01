import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../data/auth_repository.dart';

export '../../../core/models/app_user.dart' show UserRole;

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  const AuthState({
    this.selectedRole = UserRole.client,
    this.authenticatedUser,
    this.initializing = true,
  });

  final UserRole selectedRole;
  final AppUser? authenticatedUser;

  final bool initializing;

  bool get isAuthenticated => authenticatedUser != null;

  UserRole get currentRole => authenticatedUser?.role ?? selectedRole;

  AuthState copyWith({
    UserRole? selectedRole,
    AppUser? authenticatedUser,
    bool? initializing,
    bool clearUser = false,
  }) {
    return AuthState(
      selectedRole: selectedRole ?? this.selectedRole,
      authenticatedUser: clearUser ? null : (authenticatedUser ?? this.authenticatedUser),
      initializing: initializing ?? this.initializing,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<AppUser?>? _authSubscription;

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    // Subscribe to Firebase auth state changes once.
    _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges().listen(
      (user) {
        state = state.copyWith(
          authenticatedUser: user,
          selectedRole: user?.role ?? state.selectedRole,
          initializing: false,
        );
      },
      onError: (_) {
        state = state.copyWith(initializing: false);
      },
    );

    ref.onDispose(() => _authSubscription?.cancel());

    return const AuthState();
  }

  void selectRole(UserRole role) =>
      state = state.copyWith(selectedRole: role);

  void signIn(AppUser user) => state = state.copyWith(
        authenticatedUser: user,
        selectedRole: user.role,
        initializing: false,
      );

  void updateUser(AppUser user) => state = state.copyWith(
        authenticatedUser: user,
      );

  Future<void> signOut() async {
    await _repository.signOut();
    state = state.copyWith(clearUser: true);
  }
}
