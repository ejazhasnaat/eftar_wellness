// lib/features/home/application/home_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:eftar_wellness/features/home/domain/home_repository.dart';
import 'package:eftar_wellness/features/home/data/home_repository_local.dart';

class HomeState {
  final bool isLoading;
  final List<String> recommendations;
  final List<(IconData, String, String)> trackers;
  final String? error;

  const HomeState({
    required this.isLoading,
    this.recommendations = const [],
    this.trackers = const [],
    this.error,
  });

  const HomeState.initial()
      : isLoading = false,
        recommendations = const [],
        trackers = const [],
        error = null;

  HomeState copyWith({
    bool? isLoading,
    List<String>? recommendations,
    List<(IconData, String, String)>? trackers,
    String? error, // pass '' to clear
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      trackers: trackers ?? this.trackers,
      error: error == '' ? null : (error ?? this.error),
    );
  }
}

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const HomeRepositoryLocal();
});

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref)..load(); // auto-load on first read
});

class HomeController extends StateNotifier<HomeState> {
  HomeController(this._ref) : super(const HomeState.initial());
  final Ref _ref;

  HomeRepository get _repo => _ref.read(homeRepositoryProvider);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: '');
    try {
      final recs = await _repo.fetchRecommendations();
      final tr = await _repo.fetchTrackerSummaries();
      state = state.copyWith(isLoading: false, recommendations: recs, trackers: tr);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$e');
    }
  }
}
