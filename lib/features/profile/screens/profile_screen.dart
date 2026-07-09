import 'package:flutter/material.dart';

/// Owner: Profile team (Feature 5)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
