import 'package:flutter/material.dart';

/// Owner: Home & Discover team (Feature 3)
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: const Center(
        child: Text('Discover Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
