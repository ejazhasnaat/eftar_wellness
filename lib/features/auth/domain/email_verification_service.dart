abstract class EmailVerificationService {
  Future<void> sendVerification({
    required String email,
    required String code,
    Uri? magicLink,
  });

  Future<void> verify({
    required String email,
    required String code,
  });
}
