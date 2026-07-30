import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/booking.dart';
import '../../../../core/services/firestore_service.dart';

/// The only place that talks to the `bookings` collection for the client side.
class BookingRepository {
  BookingRepository({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? const FirestoreService();

  final FirestoreService _firestore;

  /// Creates a booking with status `pending` and returns its new id.
  Future<String> createBooking(Booking booking) async {
    final doc = _firestore.bookings.doc();
    await doc.set({
      ...booking.toJson(),
      'status': BookingLifecycle.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Live stream of the signed-in client's bookings, newest first.
  Stream<List<Booking>> watchClientBookings(String clientId) {
    return _firestore.bookings
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromJson(doc.id, doc.data()))
            .toList());
  }

  /// Live stream of a single booking, or null if it no longer exists.
  Stream<Booking?> watchBooking(String bookingId) {
    return _firestore.bookingDoc(bookingId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return Booking.fromJson(doc.id, data);
    });
  }

  Future<void> cancelBooking(String bookingId) {
    return _firestore.bookingDoc(bookingId).update({
      'status': BookingLifecycle.cancelled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
