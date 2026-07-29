import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  const FirestoreService();

  static FirebaseFirestore get _instance => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get users =>
      _instance.collection('users');

  CollectionReference<Map<String, dynamic>> get workers =>
      _instance.collection('workers');

  CollectionReference<Map<String, dynamic>> get bookings =>
      _instance.collection('bookings');

  CollectionReference<Map<String, dynamic>> get reviews =>
      _instance.collection('reviews');

  CollectionReference<Map<String, dynamic>> get categories =>
      _instance.collection('categories');

  DocumentReference<Map<String, dynamic>> userDoc(String uid) => users.doc(uid);

  DocumentReference<Map<String, dynamic>> workerDoc(String uid) =>
      workers.doc(uid);

  DocumentReference<Map<String, dynamic>> bookingDoc(String id) =>
      bookings.doc(id);

  DocumentReference<Map<String, dynamic>> reviewDoc(String id) =>
      reviews.doc(id);

  Future<void> batchWrite(List<Future<void> Function(WriteBatch)> operations) {
    final batch = _instance.batch();
    for (final operation in operations) {
      operation(batch);
    }
    return batch.commit();
  }

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) updateFunction,
  ) =>
      _instance.runTransaction(updateFunction);
}

