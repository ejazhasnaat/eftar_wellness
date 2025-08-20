abstract class EmailVerificationService {
  Future<void> sendVerification({
    required String email,
    required String code,
    Uri? magicLink,
  });
}
