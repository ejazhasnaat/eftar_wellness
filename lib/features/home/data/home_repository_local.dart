// lib/features/home/data/home_repository_local.dart
import 'package:flutter/material.dart';
import 'package:eftar_wellness/features/home/domain/home_repository.dart';

class HomeRepositoryLocal implements HomeRepository {
  const HomeRepositoryLocal();

  @override
  Future<List<String>> fetchRecommendations() async {
    // Mirror existing titles in RecommendationScroller
    return const [
      'High-protein vegetarian breakfasts',
      'Guide: beginner 20-min run',
      'Hydration myths debunked',
      'Sleep hygiene checklist',
    ];
  }

  @override
  Future<List<(IconData, String, String)>> fetchTrackerSummaries() async {
    // Mirror constants in TrackersGrid
    return const <(IconData, String, String)>[
      (Icons.restaurant_menu, 'Meals', '2/3'),
      (Icons.local_drink, 'Hydration', '1200/2000ml'),
      (Icons.bedtime, 'Sleep', '6h 20m'),
      (Icons.directions_run, 'Activity', '4,100'),
    ];
  }
}
