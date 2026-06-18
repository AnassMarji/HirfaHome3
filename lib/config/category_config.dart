// lib/config/category_config.dart
import 'package:flutter/material.dart';

class CategoryItem {
  final String key;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.key,
    required this.icon,
    required this.color,
  });
}

class CategoryConfig {
  CategoryConfig._();

  static const List<CategoryItem> categories = [
    CategoryItem(key: 'plomberie', icon: Icons.water_drop_outlined, color: Color(0xFF1565C0)),
    CategoryItem(key: 'electricite', icon: Icons.bolt_outlined, color: Color(0xFFF57F17)),
    CategoryItem(key: 'peinture', icon: Icons.format_paint_outlined, color: Color(0xFF6A1B9A)),
    CategoryItem(key: 'maconnerie', icon: Icons.home_repair_service, color: Color(0xFF4E342E)),
    CategoryItem(key: 'menuiserie', icon: Icons.door_back_door_outlined, color: Color(0xFF2E7D32)),
    CategoryItem(key: 'climatisation', icon: Icons.ac_unit, color: Color(0xFF00838F)),
    CategoryItem(key: 'nettoyage', icon: Icons.cleaning_services_outlined, color: Color(0xFF00897B)),
    CategoryItem(key: 'autre', icon: Icons.handyman_outlined, color: Color(0xFF546E7A)),
  ];

  static CategoryItem findByKey(String key) {
    return categories.firstWhere(
      (c) => c.key == key,
      orElse: () => const CategoryItem(key: 'autre', icon: Icons.handyman_outlined, color: Color(0xFF546E7A)),
    );
  }
}