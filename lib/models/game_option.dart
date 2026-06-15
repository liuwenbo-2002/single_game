import 'package:flutter/material.dart';

class GameOption {
  final String name;
  final IconData icon;
  final String description;
  final Color color;
  final String route;

  const GameOption({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
    this.route = '',
  });
}
