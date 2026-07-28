import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';

class HomeRepository {
  HomeRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? const FirestoreService();

  final FirestoreService _firestore;

  /// Needs the `(isOpen ASC, ratingAvg DESC)` composite index.
  Stream<List<Worker>> watchNearbyWorkers({int limit = 10}) {
    return _firestore.workers
        .where('isOpen', isEqualTo: true)
        .orderBy('ratingAvg', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Worker.fromJson(doc.id, doc.data())).toList());
  }
}
