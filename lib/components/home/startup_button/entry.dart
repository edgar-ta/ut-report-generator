import 'package:flutter/material.dart';

class StartupButtonEntry<K> {
  K value;
  String title;
  IconData icon;

  StartupButtonEntry({
    required this.value,
    required this.title,
    required this.icon,
  });
}
