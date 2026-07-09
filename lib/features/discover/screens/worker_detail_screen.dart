import 'package:flutter/material.dart';

/// Owner: Home & Discover team (Feature 3)
class WorkerDetailScreen extends StatelessWidget {
  const WorkerDetailScreen({super.key, required this.workerId});

  final String workerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Profile')),
      body: Center(
        child: Text(
          'Worker Detail Screen\nID: $workerId',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
