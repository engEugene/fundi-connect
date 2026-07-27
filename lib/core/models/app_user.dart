import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.role,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
    this.fcmToken,
    this.emailVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final UserRole role;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;
  final String? fcmToken;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser copyWith({
    String? uid,
    UserRole? role,
    String? email,
    String? phone,
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    DateTime? toDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return AppUser(
      uid: json['uid'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (json['role'] as String? ?? 'client'),
        orElse: () => UserRole.client,
      ),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      fcmToken: json['fcmToken'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: toDateTime(json['createdAt']),
      updatedAt: toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role.name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'emailVerified': emailVerified,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
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
        other.photoUrl == photoUrl &&
        other.fcmToken == fcmToken &&
        other.emailVerified == emailVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      uid,
      role,
      email,
      phone,
      displayName,
      photoUrl,
      fcmToken,
      emailVerified,
      createdAt,
      updatedAt,
    );
  }
}

enum UserRole { client, worker }
