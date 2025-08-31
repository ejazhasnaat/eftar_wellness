import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/email_verification_service.dart';

class EmailVerificationServiceSupabase implements EmailVerificationService {
  EmailVerificationServiceSupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<void> sendVerification({
    required String email,
    required String code,
    Uri? magicLink,
  }) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
  }

  @override
  Future<void> verify({
    required String email,
    required String code,
  }) async {
    await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
  }
}
