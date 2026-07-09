import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Auth team (Feature 2)
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Sign In Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RouteNames.createAccount),
              child: const Text("Don't have an account? Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
