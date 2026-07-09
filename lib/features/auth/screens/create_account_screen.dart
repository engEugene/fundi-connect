import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Auth team (Feature 2)
class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Create Account Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.verifyPhone),
              child: const Text('Create Account'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RouteNames.signIn),
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
