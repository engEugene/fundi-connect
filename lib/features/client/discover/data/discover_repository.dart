import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';

class DiscoverRepository {
  DiscoverRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? const FirestoreService();

  final FirestoreService _firestore;

  Stream<List<Category>> watchCategories() {
    return _firestore.categories
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());
  }

  /// Search and sort stay client-side on purpose: an equality-only Firestore
  /// query needs no composite index. Adding an `orderBy` here requires one.
  Future<List<Worker>> getWorkers({
    String? category,
    String searchQuery = '',
    String filter = 'All',
  }) async {
    Query<Map<String, dynamic>> query = _firestore.workers;
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    var workers =
        snapshot.docs.map((doc) => Worker.fromJson(doc.id, doc.data())).toList();

    final term = searchQuery.trim().toLowerCase();
    if (term.isNotEmpty) {
      workers = workers
          .where((w) =>
              w.name.toLowerCase().contains(term) ||
              w.category.toLowerCase().contains(term))
          .toList();
    }

    switch (filter) {
      case 'Top Rated':
        workers.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Price ↑':
        workers.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
      case 'Available':
        workers = workers.where((w) => w.isOpen).toList();
    }

    return workers;
  }

  Future<Worker?> getWorkerById(String id) async {
    final doc = await _firestore.workerDoc(id).get();
    final data = doc.data();
    if (data == null) return null;
    return Worker.fromJson(doc.id, data);
  }

  Future<List<Review>> getWorkerReviews(String workerId) async {
    final snapshot = await _firestore.reviews
        .where('workerId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromJson(doc.id, doc.data())).toList();
  }
}
