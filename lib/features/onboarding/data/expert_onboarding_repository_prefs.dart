import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../onboarding/domain/expert_onboarding_repository.dart';

class ExpertOnboardingRepositoryPrefs implements ExpertOnboardingRepository {
  static const _kKey = 'expert_profile';

  @override
  Future<void> saveExpertDetails({
    required String specialization,
    String? profilePhotoPath,
    String? portfolioUrl,
    String? linkedinUrl,
    String? bio,
    String? licenseNo,
    String? issuingAuthority,
    String? licenseExpiryIso,
    int? yearsExperience,
    String? primarySpecialty,
    String? notes,
    String? certName,
    String? certId,
    String? certExpiryIso,
    String? socialHandle,
    int? followers,
    String? businessName,
    String? address,
    bool? delivery,
    bool? pickup,
    int? deliveryRadiusKm,
    required DateTime submittedAtUtc,
    String status = 'pending',
  }) async {
    final p = await SharedPreferences.getInstance();
    final payload = {
      'specialization': specialization,
      'profile_photo_path': profilePhotoPath,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'bio': bio,
      'license_no': licenseNo,
      'issuing_authority': issuingAuthority,
      'license_expiry': licenseExpiryIso,
      'years_experience': yearsExperience,
      'primary_specialty': primarySpecialty,
      'notes': notes,
      'cert_name': certName,
      'cert_id': certId,
      'cert_expiry': certExpiryIso,
      'social_handle': socialHandle,
      'followers': followers,
      'business_name': businessName,
      'address': address,
      'delivery': delivery,
      'pickup': pickup,
      'delivery_radius_km': deliveryRadiusKm,
      'submitted_at': submittedAtUtc.toIso8601String(),
      'status': status,
    };
    await p.setString(_kKey, jsonEncode(payload));
  }
}

