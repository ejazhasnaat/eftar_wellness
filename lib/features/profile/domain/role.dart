enum UserRole { user, expert, provider, vendor, admin }

UserRole roleFromString(String? v) {
  switch (v) {
    case 'expert': return UserRole.expert;
    case 'provider': return UserRole.provider;
    case 'vendor': return UserRole.vendor;
    case 'admin': return UserRole.admin;
    default: return UserRole.user;
  }
}

String roleToString(UserRole role) => role.name;
