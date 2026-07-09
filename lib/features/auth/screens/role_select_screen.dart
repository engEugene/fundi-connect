import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/route_names.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Owner: Auth team (Feature 2)
class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  String _continueLabel(UserRole? role) {
    return switch (role) {
      UserRole.client => 'Continue as Client',
      UserRole.worker => 'Continue as Tradesman',
      _ => 'Continue',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final selectedRole = authState.selectedRole;

    return Scaffold(
      appBar: AppBar(title: const Text('How will you use Fundi Connect?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose your role to get started.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _RoleCard(
                title: 'I need a tradesman',
                subtitle: 'Post jobs and hire skilled workers near you.',
                selected: selectedRole == UserRole.client,
                onTap: () => ref.read(authProvider.notifier).selectRole(UserRole.client),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: 'I am a tradesman',
                subtitle: 'Offer your skills and grow your business.',
                selected: selectedRole == UserRole.worker,
                onTap: () => ref.read(authProvider.notifier).selectRole(UserRole.worker),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: selectedRole == null
                    ? null
                    : () => context.go(RouteNames.home),
                child: Text(_continueLabel(selectedRole)),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(RouteNames.signIn),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
              else
                const Icon(Icons.circle_outlined, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
