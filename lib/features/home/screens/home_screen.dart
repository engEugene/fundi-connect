import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Home & Discover team (Feature 3)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.searchResults),
              child: const Text('Open Search Results'),
            ),
          ],
        ),
      ),
    );
  }
}
