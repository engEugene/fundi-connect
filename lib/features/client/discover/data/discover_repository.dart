import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../reviews/data/review_repository.dart';


class DiscoverRepository {
  DiscoverRepository(this._firestore, {ReviewRepository? reviewRepository})
      : _reviews = reviewRepository ?? ReviewRepository();

  final FirestoreService _firestore;

  /// Reviews are owned by the reviews feature; Discover only reads them.
  final ReviewRepository _reviews;

  
  Stream<List<Worker>> watchWorkers({String? category, String? district}) {
    Query<Map<String, dynamic>> query = _firestore.workers;

    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Worker.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  
  Stream<Worker?> watchWorker(String workerId) {
    return _firestore.workerDoc(workerId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return Worker.fromJson(doc.id, data);
    });
  }

  /// A tradesman's reviews, newest first.
  ///
  /// Delegates to [ReviewRepository] so the `workerId` field name and the
  /// composite index it relies on are defined in exactly one place.
  Stream<List<Review>> watchReviews(String workerId) =>
      _reviews.watchWorkerReviews(workerId);

  /// Streams active categories, in display order.
  Stream<List<Category>> watchCategories() {
    return _firestore.categories
        .where('isActive', isEqualTo: true)
        .orderBy('displayOrder')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Category.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }
}

