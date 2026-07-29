import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  const StorageService();

  static FirebaseStorage get _instance => FirebaseStorage.instance;

  Future<String> uploadAvatar({
    required String uid,
    required File file,
  }) async {
    final ref = _instance.ref().child('avatars/$uid');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadPortfolioPhoto({
    required String uid,
    required String imageId,
    required File file,
  }) async {
    final ref = _instance.ref().child('portfolio/$uid/$imageId');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deletePortfolioPhoto({
    required String uid,
    required String imageId,
  }) async {
    final ref = _instance.ref().child('portfolio/$uid/$imageId');
    await ref.delete();
  }
}
