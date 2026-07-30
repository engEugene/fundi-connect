import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/booking.dart';
import '../../../auth/providers/auth_provider.dart';
import '../data/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

/// The signed-in client's bookings, streamed live from Firestore.
final clientBookingsProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final uid = ref.watch(authProvider).authenticatedUser?.uid;
  if (uid == null) return Stream.value(const []);

  return ref.watch(bookingRepositoryProvider).watchClientBookings(uid);
});

/// A single booking, streamed live so status changes reflect immediately.
final bookingDetailProvider =
    StreamProvider.autoDispose.family<Booking?, String>((ref, bookingId) {
  return ref.watch(bookingRepositoryProvider).watchBooking(bookingId);
});
