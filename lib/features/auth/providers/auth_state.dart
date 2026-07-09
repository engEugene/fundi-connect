enum UserRole { client, worker }

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.selectedRole,
    this.userId,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserRole? selectedRole;
  final String? userId;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserRole? selectedRole,
    String? userId,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
