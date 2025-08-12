// lib/features/profile/domain/role.dart

/// App-wide canonical roles:
/// - healthSeeker (Health seeking Personal)
/// - dietitian (Dietitian/Nutrition Expert)
/// - fitnessExpert (Fitness Expert)
//  - provider (Healthy Meals Provider)
//  - admin (application owner/backoffice)
enum UserRole { healthSeeker, dietitian, fitnessExpert, provider, admin }

UserRole roleFromString(String? v) {
  switch (v) {
    case 'dietitian':
      return UserRole.dietitian;
    case 'fitness_expert':
      return UserRole.fitnessExpert;
    case 'provider':
      return UserRole.provider;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.healthSeeker;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.healthSeeker:
      return 'health_seeker';
    case UserRole.dietitian:
      return 'dietitian';
    case UserRole.fitnessExpert:
      return 'fitness_expert';
    case UserRole.provider:
      return 'provider';
    case UserRole.admin:
      return 'admin';
  }
}

