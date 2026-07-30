import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';


class DiscoverRepository {
  const DiscoverRepository(this._firestore);

  final FirestoreService _firestore;

  
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

 
  Stream<List<Review>> watchReviews(String workerId) {
    return _firestore.reviews
        .where('tradesmanId', isEqualTo: workerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Review.fromJson(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Streams active categories, in display order.
  ///
  /// NOTE: same as above — `isActive` equality + `orderBy displayOrder`
  /// needs a composite index. See the note at the bottom of this file.
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

