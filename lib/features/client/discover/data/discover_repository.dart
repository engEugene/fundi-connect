import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/category.dart';
import '../../../../core/models/review.dart';
import '../../../../core/models/worker.dart';
import '../../../../core/services/firestore_service.dart';

/// Read-only Firestore access for the Discover feature (Phase 3).
///
/// Category and district filters are applied server-side via Firestore
/// equality `where` clauses. Search text and sort order are applied
/// client-side in `discoverWorkersProvider` since those change on every
/// keystroke/tap and don't warrant a fresh Firestore query each time.
class DiscoverRepository {
  const DiscoverRepository(this._firestore);

  final FirestoreService _firestore;

  /// Streams the `workers` collection, optionally narrowed to a single
  /// category and/or district. Both are plain equality filters — no
  /// composite index required as long as neither is combined with an
  /// `orderBy` on a different field.
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

  /// Streams a single worker document — this is what makes availability
  /// (`isOpen`) update live on the Worker Detail screen without a refresh.
  Stream<Worker?> watchWorker(String workerId) {
    return _firestore.workerDoc(workerId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return Worker.fromJson(doc.id, data);
    });
  }

  /// Streams reviews for one worker, newest first.
  ///
  /// NOTE: this combines an equality filter (`tradesmanId`) with an
  /// `orderBy` on a different field (`createdAt`) — Firestore will require
  /// a composite index the first time this runs. See the note at the
  /// bottom of this file for how to create it.
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

// -----------------------------------------------------------------------
// FIRESTORE INDEXES REQUIRED — read this before running the app.
//
// Two queries above combine an equality filter with `orderBy` on a
// different field. Firestore requires a composite index for that combo,
// and the queries will fail at runtime (not compile time) until the index
// exists.
//
// Easiest way to create them: run the app, trigger each query (open
// Discover, open a worker's detail screen), and check the debug console —
// Firestore prints a direct link that creates the exact index needed with
// one click. Do this once per query:
//   1. `reviews` — equality on tradesmanId + orderBy createdAt desc
//   2. `categories` — equality on isActive + orderBy displayOrder asc
//
// Alternatively, create them manually in the Firebase Console under
// Firestore → Indexes → Composite, matching the fields above.
// -----------------------------------------------------------------------