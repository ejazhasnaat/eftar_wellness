abstract class ExpertOnboardingRepository {
  Future<void> saveExpertDetails({
    required String specialization, // ExpertKind.name
    // Common
    String? profilePhotoPath,
    String? portfolioUrl,
    String? linkedinUrl,
    String? bio,
    // License-related
    String? licenseNo,
    String? issuingAuthority,
    String? licenseExpiryIso, // ISO-8601 date
    int? yearsExperience,
    // Specialty
    String? primarySpecialty,
    String? notes,
    // Fitness (soft criteria)
    String? certName,
    String? certId,
    String? certExpiryIso,
    String? socialHandle,
    int? followers,
    // Healthy meals provider
    String? businessName,
    String? address,
    bool? delivery,
    bool? pickup,
    int? deliveryRadiusKm,
    // Submission
    required DateTime submittedAtUtc,
    String status = 'pending',
  });
}

