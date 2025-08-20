import 'dart:developer';

import '../domain/email_verification_service.dart';

class DevEmailVerificationService implements EmailVerificationService {
  const DevEmailVerificationService();

  @override
  Future<void> sendVerification({
    required String email,
    required String code,
    Uri? magicLink,
  }) async {
    log('[DEV MAIL] To: $email | Code: $code');
  }
}
