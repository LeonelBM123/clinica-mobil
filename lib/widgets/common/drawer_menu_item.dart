import 'package:flutter/material.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final List<DrawerSubItem>? subItems;
  final VoidCallback? onTap;

  DrawerMenuItem({
    required this.title,
    required this.icon,
    this.subItems,
    this.onTap,
  });
}

class DrawerSubItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  DrawerSubItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}