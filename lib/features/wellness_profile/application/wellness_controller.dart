import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';
import '../data/user_wellness_repository_prefs.dart';

/// Repository DI
final userWellnessRepositoryProvider = Provider<UserWellnessRepository>((ref) {
  return UserWellnessRepositoryPrefs(); // swap with Supabase later
});

/// State
final wellnessProfileProvider =
    StateNotifierProvider<WellnessController, UserWellnessProfile>((ref) {
  return WellnessController(ref);
});

class WellnessController extends StateNotifier<UserWellnessProfile> {
  WellnessController(this._ref) : super(const UserWellnessProfile()) {
    _init();
  }

  final Ref _ref;

  Future<void> _init() async {
    final loaded = await _ref.read(userWellnessRepositoryProvider).load();
    state = loaded;
  }

  Future<void> _persist(UserWellnessProfile next) async {
    state = next;
    await _ref.read(userWellnessRepositoryProvider).save(next);
  }

  // ---------- Basics ----------
  Future<void> setSex(Sex? sex) => _persist(state.copyWith(sex: sex));

  Future<void> setUnits(Units u) async {
    await _persist(state.copyWith(units: u));
    _recalcBmi();
  }

  Future<void> setHeightCm(double? cm) async {
    // When user inputs Height/Weight, BMI should be auto/computed and editable disabled
    final next = state.copyWith(
      heightCm: cm,
      // if both present, compute BMI; else keep as-is (may be null)
      bmi: UserWellnessProfile.calcBmi(heightCm: cm, weightKg: state.weightKg),
    );
    await _persist(next);
  }

  Future<void> setWeightKg(double? kg) async {
    final next = state.copyWith(
      weightKg: kg,
      bmi: UserWellnessProfile.calcBmi(heightCm: state.heightCm, weightKg: kg),
    );
    await _persist(next);
  }

  Future<void> setBmi(double? bmi) async {
    // If BMI is provided, clear height & weight to enforce mutual exclusivity
    final next = state.copyWith(
      bmi: bmi,
      heightCm: bmi != null ? null : state.heightCm,
      weightKg: bmi != null ? null : state.weightKg,
    );
    await _persist(next);
  }

  // Deprecated in UI (kept for back-compat in model). Expose setter if needed elsewhere.
  Future<void> setWaistCm(double? cm) => _persist(state.copyWith(waistCm: cm));

  Future<void> setPhotoPath(String? path) => _persist(state.copyWith(photoPath: path));

  // ---------- Goals & Activity ----------
  Future<void> setGoalPrimary(GoalPrimary? g) async {
    // If primary is not "Other", clear the free-text field
    final next = state.copyWith(
      goalPrimary: g,
      goalOther: (g == GoalPrimary.other) ? state.goalOther : null,
    );
    await _persist(next);
  }

  Future<void> setGoalOther(String? other) async {
    await _persist(state.copyWith(goalOther: (other == null || other.isEmpty) ? null : other));
  }

  Future<void> setMedicalConditions(List<String> v) => _persist(state.copyWith(medicalConditions: v));
  Future<void> setAllergies(List<String> v) => _persist(state.copyWith(allergies: v));
  Future<void> setIntolerances(List<String> v) => _persist(state.copyWith(intolerances: v));
  Future<void> setDietPreferences(List<String> v) => _persist(state.copyWith(dietPreferences: v));

  Future<void> setHabits(Habits h) => _persist(state.copyWith(habits: h));
  Future<void> setActivity(Activity a) => _persist(state.copyWith(activity: a));
  Future<void> setSleepHours(double? s) => _persist(state.copyWith(sleepHours: s));

  // ---------- Submit ----------
  Future<void> submit() async {
    final next = state.copyWith(
      submittedAt: DateTime.now().toUtc(),
      status: ProfileStatus.pending,
    );
    await _persist(next);
  }

  bool get isMinimalValid {
    final hasBody = (state.heightCm != null && state.weightKg != null) || (state.bmi != null);
    final hasGoal = state.goalPrimary != null;
    return hasBody && hasGoal;
  }

  void _recalcBmi() {
    final bmi = UserWellnessProfile.calcBmi(
      heightCm: state.heightCm,
      weightKg: state.weightKg,
    );
    _persist(state.copyWith(bmi: bmi));
  }
}

