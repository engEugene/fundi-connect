import 'package:flutter/material.dart';

/// Category shown in the Home screen horizontal list.
class Category {
  const Category({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;

  static const List<Category> all = [
    Category(name: 'Plumber', icon: Icons.water_drop),
    Category(name: 'Electrician', icon: Icons.bolt),
    Category(name: 'Carpenter', icon: Icons.handyman),
    Category(name: 'Cleaner', icon: Icons.auto_awesome),
    Category(name: 'Mason', icon: Icons.apartment),
  ];
}
