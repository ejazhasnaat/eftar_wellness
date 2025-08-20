// lib/features/onboarding/application/expert_onboarding_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eftar_wellness/features/onboarding/domain/expert_onboarding_repository.dart';
import 'package:eftar_wellness/features/onboarding/data/expert_onboarding_repository_prefs.dart';
import 'package:eftar_wellness/features/onboarding/domain/expert_kind.dart';

/// DI: current repository implementation (Prefs). Swap to remote later.
final expertOnboardingRepositoryProvider = Provider<ExpertOnboardingRepository>((ref) {
  return ExpertOnboardingRepositoryPrefs();
});

/// Minimal state to reflect submit progress & last status.
class ExpertOnboardingState {
  final bool isSubmitting;
  final String? error;
  final String status; // 'pending', 'approved', 'rejected' etc.

  const ExpertOnboardingState({
    required this.isSubmitting,
    required this.status,
    this.error,
  });

  const ExpertOnboardingState.initial()
      : isSubmitting = false,
        status = 'pending',
        error = null;

  ExpertOnboardingState copyWith({
    bool? isSubmitting,
    String? status,
    String? error, // pass empty string to clear
  }) {
    return ExpertOnboardingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: status ?? this.status,
      error: (error == '') ? null : (error ?? this.error),
    );
  }
}

/// Use this provider to access controller methods from the UI:
///   final ctrl = ref.read(expertOnboardingControllerProvider);
final expertOnboardingControllerProvider =
    StateNotifierProvider<ExpertOnboardingController, ExpertOnboardingState>((ref) {
  return ExpertOnboardingController(ref);
});

class ExpertOnboardingController extends StateNotifier<ExpertOnboardingState> {
  ExpertOnboardingController(this._ref) : super(const ExpertOnboardingState.initial());

  final Ref _ref;

  ExpertOnboardingRepository get _repo => _ref.read(expertOnboardingRepositoryProvider);

  /// Submit expert details. Mirrors the domain repository signature.
  Future<bool> saveExpertDetails({
    required ExpertKind expertKind,
    // Common
    String? profilePhotoPath,
    String? portfolioUrl,
    String? linkedinUrl,
    String? bio,
    // License-related
    String? licenseNo,
    String? issuingAuthority,
    String? licenseExpiryIso,
    int? yearsExperience,
    // Specialty
    String? primarySpecialty,
    String? notes,
    // Certifications
    String? certName,
    String? certId,
    String? certExpiryIso,
    // Social
    String? socialHandle,
    int? followers,
    // Business (for healthy meals provider)
    String? businessName,
    String? address,
    bool? delivery,
    bool? pickup,
    int? deliveryRadiusKm,
  }) async {
    state = state.copyWith(isSubmitting: true, error: '');
    try {
      await _repo.saveExpertDetails(
        specialization: expertKind.nameKey,
        profilePhotoPath: profilePhotoPath,
        portfolioUrl: portfolioUrl,
        linkedinUrl: linkedinUrl,
        bio: bio,
        licenseNo: licenseNo,
        issuingAuthority: issuingAuthority,
        licenseExpiryIso: licenseExpiryIso,
        yearsExperience: yearsExperience,
        primarySpecialty: primarySpecialty,
        notes: notes,
        certName: certName,
        certId: certId,
        certExpiryIso: certExpiryIso,
        socialHandle: socialHandle,
        followers: followers,
        businessName: businessName,
        address: address,
        delivery: delivery,
        pickup: pickup,
        deliveryRadiusKm: deliveryRadiusKm,
        submittedAtUtc: DateTime.now().toUtc(),
        status: 'pending',
      );
      state = state.copyWith(isSubmitting: false, status: 'pending');
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: '$e');
      return false;
    }
  }
}
