import 'models.dart';

/// Remote contract (Supabase/Postgres) — no implementation here.
abstract class UserWellnessRepositoryRemote {
  Future<UserWellnessProfile> fetchProfile(String userUid);
  Future<void> saveProfile(String userUid, UserWellnessProfile profile);
}
