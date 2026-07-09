import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';

/// Owner: Onboarding team (Feature 1)
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Onboarding Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.roleSelect),
              child: const Text('Get Started'),
            ),
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
