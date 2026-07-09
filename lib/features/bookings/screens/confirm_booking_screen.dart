import 'package:flutter/material.dart';

/// Owner: Bookings team (Feature 4)
class ConfirmBookingScreen extends StatelessWidget {
  const ConfirmBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: const Center(
        child: Text('Confirm Booking Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
