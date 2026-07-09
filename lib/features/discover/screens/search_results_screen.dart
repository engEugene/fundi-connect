import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Home & Discover team (Feature 3)
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Search Results Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('${RouteNames.discover}/worker/1'),
              child: const Text('Open Worker Detail'),
            ),
          ],
        ),
      ),
    );
  }
}
