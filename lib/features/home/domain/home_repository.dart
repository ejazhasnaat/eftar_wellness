// lib/features/home/domain/home_repository.dart
import 'package:flutter/material.dart';

/// Contract for home data (recommendations, tracker summaries, etc.).
abstract class HomeRepository {
  Future<List<String>> fetchRecommendations();
  Future<List<(IconData, String, String)>> fetchTrackerSummaries();
}
