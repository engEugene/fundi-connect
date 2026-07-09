import 'package:flutter/material.dart';

/// Owner: Bookings team (Feature 4)
class WorkerDashboardScreen extends StatelessWidget {
  const WorkerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Dashboard')),
      body: const Center(
        child: Text('Worker Dashboard Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
