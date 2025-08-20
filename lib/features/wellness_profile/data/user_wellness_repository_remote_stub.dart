import 'package:eftar_wellness/features/wellness_profile/domain/models.dart';
import 'package:eftar_wellness/features/wellness_profile/domain/repository_remote.dart';

/// Placeholder remote impl. Not wired into DI. Safe no-op.
class UserWellnessRepositoryRemoteStub implements UserWellnessRepositoryRemote {
  @override
  Future<UserWellnessProfile> fetchProfile(String userUid) async {
    // In the future, call Supabase here. For now, return an empty/draft profile.
    return const UserWellnessProfile();
  }

  @override
  Future<void> saveProfile(String userUid, UserWellnessProfile profile) async {
    // In the future, push to Supabase.
  }
}
