// lib/features/onboarding/domain/expert_onboarding_repository_remote.dart
import 'package:eftar_wellness/features/onboarding/domain/expert_kind.dart';

/// Remote seam (e.g., Supabase). Not wired yet.
abstract class ExpertOnboardingRepositoryRemote {
  Future<void> submit({
    required ExpertKind expertKind,
    Map<String, dynamic>? payload,
  });

  /// Optionally poll review status later.
  Future<String> reviewStatus({required String userId});
}
