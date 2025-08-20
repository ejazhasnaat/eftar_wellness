// lib/features/home/domain/models.dart
import 'package:flutter/material.dart';

class Recommendation {
  final String title;
  const Recommendation(this.title);
}

class TrackerSummary {
  final IconData icon;
  final String title;
  final String value;
  const TrackerSummary({required this.icon, required this.title, required this.value});
}
