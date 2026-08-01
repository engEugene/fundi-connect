import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';

class WorkerProfileRepository {
  WorkerProfileRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestore = firestoreService ?? const FirestoreService(),
        _storage = storageService ?? const StorageService();

  final FirestoreService _firestore;
  final StorageService _storage;

  Future<Worker?> getWorkerProfile(String uid) async {
    final doc = await _firestore.workerDoc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return Worker.fromJson(doc.id, data);
  }

  Future<void> updateWorkerProfile(Worker worker) {
    return _firestore.workerDoc(worker.id).set({
      ...worker.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateAvailability({
    required String uid,
    required bool isOpen,
  }) {
    return _firestore.workerDoc(uid).set({
      'isOpen': isOpen,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final photoUrl = await _storage.uploadAvatar(uid: uid, file: file);
    final update = {
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.workerDoc(uid).set(update, SetOptions(merge: true));
    await _firestore.userDoc(uid).set(update, SetOptions(merge: true));

    return photoUrl;
  }

  Future<String> uploadPortfolioPhoto({
    required String uid,
    required File file,
  }) async {
    final photoUrl = await _storage.uploadPortfolioPhoto(
      uid: uid,
      imageId: DateTime.now().millisecondsSinceEpoch.toString(),
      file: file,
    );

    await _firestore.workerDoc(uid).set({
      'portfolioUrls': FieldValue.arrayUnion([photoUrl]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return photoUrl;
  }
}
