import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { client, worker }

// role stays here, signed-in state comes from firebase later
class AuthState {
  const AuthState({this.selectedRole = UserRole.client});

  final UserRole selectedRole;
}

// using Notifier bcs StateNotifier got removed in rvpd 3
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void selectRole(UserRole role) => state = AuthState(selectedRole: role);

  // TODO: also call firebase signout
  void signOut() => state = const AuthState();
}
