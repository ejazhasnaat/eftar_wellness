// lib/features/onboarding/data/expert_onboarding_repository_remote_stub.dart
import 'package:eftar_wellness/features/onboarding/domain/expert_kind.dart';
import 'package:eftar_wellness/features/onboarding/domain/expert_onboarding_repository_remote.dart';

/// No-op remote stub used during local-only development.
class ExpertOnboardingRepositoryRemoteStub implements ExpertOnboardingRepositoryRemote {
  @override
  Future<void> submit({required ExpertKind expertKind, Map<String, dynamic>? payload}) async {
    // TODO: Implement Supabase call later.
  }

  @override
  Future<String> reviewStatus({required String userId}) async {
    return 'pending';
  }
}
