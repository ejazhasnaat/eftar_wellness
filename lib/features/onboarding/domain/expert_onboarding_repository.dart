abstract class ExpertOnboardingRepository {
  Future<void> saveExpertDetails({
    required String specialization, // ExpertKind.name
    String? portfolioUrl,
    String? linkedinUrl,
    String? licenseNo,
    int? yearsExperience,
    String? primarySpecialty,
    String? notes,
    required DateTime submittedAtUtc,
    String status = 'pending',
  });
}

