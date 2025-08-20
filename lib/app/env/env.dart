import 'dart:convert';

/// App flavors
enum AppFlavor { dev, stage, prod }

/// Strongly-typed environment configuration loaded at startup.
class EnvConfig {
  final AppFlavor flavor;
  final Uri? apiBaseUrl;
  final Map<String, bool> featureFlags;

  const EnvConfig({
    required this.flavor,
    this.apiBaseUrl,
    this.featureFlags = const {},
  });

  bool isEnabled(String flag) => featureFlags[flag] == true;
}

/// Loads environment variables from --dart-define values.
/// Example:
///   --dart-define=FLAVOR=dev
///   --dart-define=API_BASE_URL=https://api.dev.example.com
///   --dart-define=FEATURE_FLAGS={"newAiFlow":true,"betaX":false}
class EnvLoader {
  static EnvConfig load() {
    final flavorRaw = const String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    final apiRaw = const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final flagsRaw = const String.fromEnvironment('FEATURE_FLAGS', defaultValue: '{}');

    final flavor = _parseFlavor(flavorRaw);
    Uri? api;
    if (apiRaw.isNotEmpty) {
      try { api = Uri.parse(apiRaw); } catch (_) {}
    }
    Map<String, bool> flags = const {};
    try {
      final decoded = jsonDecode(flagsRaw);
      if (decoded is Map<String, dynamic>) {
        flags = decoded.map((k, v) => MapEntry(k, v == true));
      }
    } catch (_) {}

    return EnvConfig(flavor: flavor, apiBaseUrl: api, featureFlags: flags);
  }

  static AppFlavor _parseFlavor(String s) {
    switch (s.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppFlavor.prod;
      case 'stage':
      case 'staging':
        return AppFlavor.stage;
      default:
        return AppFlavor.dev;
    }
  }
}
