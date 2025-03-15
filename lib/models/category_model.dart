import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final Widget? icon;
  final String? image;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.image,
  });
}
