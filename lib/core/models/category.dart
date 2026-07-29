import 'package:flutter/material.dart';

/// Category shown in the Home screen horizontal list.
class Category {
  const Category({
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json['name'] as String? ?? '',
        icon: iconFor(json['iconName'] as String?),
      );

  final String name;
  final IconData icon;

  static IconData iconFor(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'bolt':
        return Icons.bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'handyman':
        return Icons.handyman;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'apartment':
        return Icons.apartment;
      default:
        return Icons.build;
    }
  }

  static const List<Category> all = [
    Category(name: 'Plumber', icon: Icons.water_drop),
    Category(name: 'Electrician', icon: Icons.bolt),
    Category(name: 'Carpenter', icon: Icons.handyman),
    Category(name: 'Cleaner', icon: Icons.auto_awesome),
    Category(name: 'Mason', icon: Icons.apartment),
  ];
}
