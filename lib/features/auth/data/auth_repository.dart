import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/app_user.dart';
import '../../../core/services/firestore_service.dart';

export '../../../core/models/app_user.dart' show UserRole;


class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestoreService ?? const FirestoreService();

  final FirebaseAuth _auth;
  final FirestoreService _firestore;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _getUserDocument(firebaseUser.uid);
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserDocument(firebaseUser.uid);
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }

      final appUser = await _getUserDocument(firebaseUser.uid);
      if (appUser == null) {
        final fallback = _appUserFromFirebase(
          firebaseUser,
          role: UserRole.client,
        );
        await _createUserDocument(fallback);
        return fallback;
      }
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<AppUser> createAccountWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }

      await firebaseUser.updateDisplayName(name.trim());
      await firebaseUser.reload();
      final refreshedUser = _auth.currentUser!;

      final appUser = _appUserFromFirebase(
        refreshedUser,
        role: role,
        phone: phone?.trim(),
      );
      await _createUserDocument(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> verifyPhoneNumber(String phoneNumber) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!completer.isCompleted) {
          completer.complete(credential.verificationId ?? '');
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(AuthException(_mapFirebaseAuthError(e)));
        }
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  Future<AppUser> linkPhoneCredential(
    String verificationId,
    String smsCode,
  ) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException('No signed-in user. Please sign in again.');
      }

      await firebaseUser.updatePhoneNumber(credential);
      await firebaseUser.reload();
      final refreshedUser = _auth.currentUser!;

      final current = await _getUserDocument(refreshedUser.uid);
      final updated = (current ?? _appUserFromFirebase(refreshedUser, role: UserRole.client))
          .copyWith(
        phone: refreshedUser.phoneNumber,
        updatedAt: DateTime.now(),
      );
      await _createUserDocument(updated);
      return updated;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<AppUser?> _getUserDocument(String uid) async {
    try {
      final doc = await _firestore.userDoc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  Future<void> _createUserDocument(AppUser user) async {
    final now = DateTime.now();
    final doc = user.copyWith(
      createdAt: user.createdAt ?? now,
      updatedAt: now,
    );
    await _firestore.userDoc(user.uid).set(doc.toJson(), SetOptions(merge: true));
  }

  AppUser _appUserFromFirebase(
    User firebaseUser, {
    required UserRole role,
    String? phone,
  }) {
    return AppUser(
      uid: firebaseUser.uid,
      role: role,
      email: firebaseUser.email,
      phone: phone ?? firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Password is too weak. Use at least 8 characters.',
      'too-many-requests' =>
        'Too many attempts. Please wait a moment and try again.',
      'invalid-verification-code' => 'Invalid verification code.',
      'invalid-verification-id' => 'Verification session expired. Resend code.',
      'session-expired' => 'Verification session expired. Resend code.',
      _ => e.message ?? 'Something went wrong. Please try again.',
    };
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

