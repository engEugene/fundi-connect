/// Authenticated user account.
///
/// Mirrors the `users/{uid}` Firestore document. One account has one role:
/// [client] or [worker].
class AppUser {
  const AppUser({
    required this.uid,
    required this.role,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;

  AppUser copyWith({
    String? uid,
    UserRole? role,
    String? email,
    String? phone,
    String? displayName,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.uid == uid &&
        other.role == role &&
        other.email == email &&
        other.phone == phone &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return Object.hash(uid, role, email, phone, displayName, photoUrl);
  }
}

enum UserRole { client, worker }
