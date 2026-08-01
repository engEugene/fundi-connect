import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      return _getOrCreateUserDocument(firebaseUser);
    });
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getOrCreateUserDocument(firebaseUser);
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

      return _getOrCreateUserDocument(firebaseUser);
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
      if (role == UserRole.worker) {
        await _createInitialWorkerDocument(appUser);
      }
      try {
        await _sendEmailVerification(refreshedUser);
      } catch (_) {}
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthException('Google sign-in failed. Please try again.');
      }

      return _getOrCreateUserDocument(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on PlatformException catch (e) {
      debugPrint('Google sign-in platform error: code=${e.code} '
          'message=${e.message} details=${e.details}');
      throw AuthException(_mapPlatformError(e));
    } on AuthException {
      rethrow;
    } catch (e, st) {
      debugPrint('Google sign-in error: $e\n$st');
      throw const AuthException('Google sign-in failed. Please try again.');
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

  Future<void> sendEmailVerification() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.emailVerified) return;
    await _sendEmailVerification(firebaseUser);
  }

  Future<AppUser?> reloadEmailVerificationStatus() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    await firebaseUser.reload();
    final refreshedUser = _auth.currentUser!;
    final current = await _getUserDocument(refreshedUser.uid);
    final updated = (current ?? _appUserFromFirebase(refreshedUser, role: UserRole.client))
        .copyWith(emailVerified: refreshedUser.emailVerified);
    await _createUserDocument(updated);
    return updated;
  }

  Future<void> _sendEmailVerification(User firebaseUser) async {
    try {
      await firebaseUser.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    }
  }

  Future<AppUser> _getOrCreateUserDocument(User firebaseUser) async {
    final fromFirestore = await _getUserDocument(firebaseUser.uid);
    if (fromFirestore != null) {
      final updated = fromFirestore.copyWith(
        emailVerified: firebaseUser.emailVerified,
      );
      if (updated.emailVerified != fromFirestore.emailVerified) {
        await _createUserDocument(updated);
      }
      if (updated.role == UserRole.worker) {
        await _createInitialWorkerDocument(updated);
      }      return updated;
    }

    // If the users document is missing, infer the role from an existing
    // worker document so we don't accidentally downgrade a worker to client.
    final workerDocExists = await _workerDocExists(firebaseUser.uid);
    final fallbackRole = workerDocExists ? UserRole.worker : UserRole.client;
    final fallback = _appUserFromFirebase(
      firebaseUser,
      role: fallbackRole,
    );

    // Create the fallback document inside a transaction that re-checks
    // existence, so a concurrently created document (e.g. a sign-up that
    // is still writing its worker role) is never overwritten with the
    // fallback's inferred role.
    final created = await _firestore.runTransaction((txn) async {
      final ref = _firestore.userDoc(firebaseUser.uid);
      final existing = await txn.get(ref);
      if (existing.exists) {
        return AppUser.fromJson(existing.data()!);
      }
      txn.set(ref, fallback.toJson());
      return fallback;
    });
    if (created.role == UserRole.worker) {
      await _createInitialWorkerDocument(created);
    }
    return created;
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

  /// Persists editable profile fields (name, phone) to the `users` doc.
  Future<void> updateProfile(AppUser user) async {
    await _firestore.userDoc(user.uid).set({
      'displayName': user.displayName,
      'phone': user.phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Creates a minimal `workers/{uid}` document for a newly registered tradesman.
  /// The worker fills in the rest from the Edit Profile screen.
  Future<void> _createInitialWorkerDocument(AppUser user) async {
    if (await _workerDocExists(user.uid)) return;
    final now = DateTime.now();
    final data = {
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'category': '',
      'hourlyRate': 0,
      'currency': 'RWF',
      'yearsExp': 0,
      'bio': '',
      'isOpen': false,
      'isVerified': false,
      'district': '',
      'jobsDone': 0,
      'ratingAvg': 0.0,
      'reviewCount': 0,
      'portfolioUrls': <String>[],
      'availability': <String, dynamic>{},
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };
    await _firestore
        .workerDoc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  Future<bool> _workerDocExists(String uid) async {
    try {
      final doc = await _firestore.workerDoc(uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
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
      emailVerified: firebaseUser.emailVerified,
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
      'account-exists-with-different-credential' =>
        'An account already exists with this email. '
            'Sign in with your email and password instead.',
      'operation-not-allowed' =>
        'Google sign-in is not available yet. Please try again later.',
      _ => e.message ?? 'Something went wrong. Please try again.',
    };
  }

  String _mapPlatformError(PlatformException e) {
    return switch (e.code) {
      'sign_in_canceled' => 'Google sign-in was cancelled.',
      'sign_in_failed' || 'sign_in_required' =>
        'Google sign-in failed. Please try again.',
      'network_error' => 'Network error. Check your connection and try again.',
      _ => 'Google sign-in failed. Please try again.',
    };
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

