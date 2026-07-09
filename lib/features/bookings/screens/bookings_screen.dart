import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Bookings team (Feature 4)
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bookings Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('${RouteNames.bookings}/1'),
              child: const Text('Open Booking Detail'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.confirmBooking),
              child: const Text('Confirm Booking'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.workerDashboard),
              child: const Text('Worker Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
