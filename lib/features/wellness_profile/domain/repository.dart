// lib/features/wellness_profile/domain/repository.dart
import 'models.dart';

/// Domain-level contract (UI/application depend on this)
abstract class UserWellnessRepository {
  Future<UserWellnessProfile> load();
  Future<void> save(UserWellnessProfile profile);
}

