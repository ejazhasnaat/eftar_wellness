import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../onboarding/domain/expert_onboarding_repository.dart';

class ExpertOnboardingRepositoryPrefs implements ExpertOnboardingRepository {
  static const _kKey = 'expert_profile';

  @override
  Future<void> saveExpertDetails({
    required String specialization,
    String? portfolioUrl,
    String? linkedinUrl,
    String? licenseNo,
    int? yearsExperience,
    String? primarySpecialty,
    String? notes,
    required DateTime submittedAtUtc,
    String status = 'pending',
  }) async {
    final p = await SharedPreferences.getInstance();
    final payload = {
      'specialization': specialization,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'license_no': licenseNo,
      'years_experience': yearsExperience,
      'primary_specialty': primarySpecialty,
      'notes': notes,
      'submitted_at': submittedAtUtc.toIso8601String(),
      'status': status,
    };
    await p.setString(_kKey, jsonEncode(payload));
  }
}

