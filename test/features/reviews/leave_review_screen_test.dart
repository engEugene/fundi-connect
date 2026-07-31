import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fundi_connect/core/models/booking.dart';
import 'package:fundi_connect/core/models/worker.dart';
import 'package:fundi_connect/features/client/bookings/providers/booking_providers.dart';
import 'package:fundi_connect/features/reviews/providers/review_providers.dart';
import 'package:fundi_connect/features/reviews/screens/leave_review_screen.dart';
import 'package:fundi_connect/features/reviews/widgets/star_rating.dart';

/// Widget tests for the review flow.
///
/// Firestore is never touched: [bookingDetailProvider] is overridden with a
/// fixed booking, so these exercise the UI and the Riverpod form state only.
void main() {
  setUpAll(() {
    // Stops google_fonts from attempting a network fetch during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const bookingId = 'booking-1';

  const worker = Worker(
    id: 'worker-1',
    name: 'Jean Pierre Habimana',
    role: 'Electrician',
    category: 'Electrician',
    imageUrl: '',
    rating: 4.9,
    reviewCount: 56,
    distanceKm: 0.8,
    hourlyRate: 6000,
  );

  Booking bookingWith({
    required BookingStatus status,
    bool isRated = false,
  }) {
    return Booking(
      id: bookingId,
      worker: worker,
      serviceType: 'Wiring & Installation',
      date: DateTime(2026, 5, 20),
      time: '10:00 AM',
      location: 'KG 14 Ave, Kacyiru, Kigali',
      status: status,
      statusRaw: status == BookingStatus.completed
          ? BookingLifecycle.completed
          : BookingLifecycle.pending,
      isRated: isRated,
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Booking booking) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookingDetailProvider(bookingId)
              .overrideWith((ref) => Stream<Booking?>.value(booking)),
        ],
        child: const MaterialApp(
          home: LeaveReviewScreen(bookingId: bookingId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LeaveReviewScreen', () {
    testWidgets('shows the tradesman and an empty star picker', (tester) async {
      await pumpScreen(tester, bookingWith(status: BookingStatus.completed));

      expect(find.text('Jean Pierre Habimana'), findsOneWidget);
      expect(find.text('Wiring & Installation'), findsOneWidget);
      expect(find.byType(StarRatingInput), findsOneWidget);
      expect(find.text('Tap a star to rate'), findsOneWidget);
    });

    testWidgets('keeps Submit disabled until a rating is chosen',
        (tester) async {
      await pumpScreen(tester, bookingWith(status: BookingStatus.completed));

      final submit = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Review'),
      );
      expect(submit.onPressed, isNull);
    });

    testWidgets('tapping a star updates the label and enables Submit',
        (tester) async {
      await pumpScreen(tester, bookingWith(status: BookingStatus.completed));

      // Tap the fifth star.
      await tester.tap(find.byIcon(Icons.star_border_rounded).at(4));
      await tester.pumpAndSettle();

      expect(find.text('Excellent'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));

      final submit = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Review'),
      );
      expect(submit.onPressed, isNotNull);
    });

    testWidgets('refuses to rate a job that is not completed yet',
        (tester) async {
      await pumpScreen(tester, bookingWith(status: BookingStatus.upcoming));

      expect(
        find.text('You can rate this job once it has been completed.'),
        findsOneWidget,
      );
      expect(find.byType(StarRatingInput), findsNothing);
    });

    testWidgets('refuses to rate the same booking twice', (tester) async {
      await pumpScreen(
        tester,
        bookingWith(status: BookingStatus.completed, isRated: true),
      );

      expect(
        find.text('You have already reviewed this booking. Thank you!'),
        findsOneWidget,
      );
      expect(find.byType(StarRatingInput), findsNothing);
    });
  });

  group('ReviewFormState', () {
    test('cannot submit without a rating', () {
      const state = ReviewFormState();
      expect(state.canSubmit, isFalse);
    });

    test('can submit once a valid rating is set', () {
      const state = ReviewFormState(rating: 4);
      expect(state.canSubmit, isTrue);
    });

    test('cannot submit while a write is in flight', () {
      const state = ReviewFormState(rating: 4, isSubmitting: true);
      expect(state.canSubmit, isFalse);
    });

    test('counts the characters left in the comment', () {
      const state = ReviewFormState(rating: 5, comment: 'Great job');
      expect(state.remainingCharacters, 500 - 'Great job'.length);
    });
  });

  group('StarRatingInput.labelFor', () {
    test('describes each star value in words', () {
      expect(StarRatingInput.labelFor(0), 'Tap a star to rate');
      expect(StarRatingInput.labelFor(1), 'Poor');
      expect(StarRatingInput.labelFor(3), 'Good');
      expect(StarRatingInput.labelFor(5), 'Excellent');
    });
  });
}
