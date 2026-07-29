import 'package:flutter/material.dart';


class Category {
  const Category({
    this.id = '',
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json['name'] as String? ?? '',
        icon: iconFor(json['iconName'] as String?),
      );

  /// Use this when reading from a Firestore `categories` document, so the
  /// category carries its doc id (needed to filter workers by category).
  factory Category.fromFirestore(String id, Map<String, dynamic> json) =>
      Category(
        id: id,
        name: json['name'] as String? ?? '',
        icon: iconFor(json['iconName'] as String?),
      );

  final String id;
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