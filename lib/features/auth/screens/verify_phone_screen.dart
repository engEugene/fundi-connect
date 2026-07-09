import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Auth team (Feature 2)
class VerifyPhoneScreen extends StatelessWidget {
  const VerifyPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verify Phone Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Verify Code'),
            ),
          ],
        ),
      ),
    );
  }
}
