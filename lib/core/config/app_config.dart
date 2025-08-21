import 'dart:io';

/// Provides configuration values sourced from environment variables.
///
/// These values are intended for wiring remote services and should only
/// contain public client keys. Server-side secrets must never be bundled
/// with the application.
class AppConfig {
  AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.llmProvider,
    this.openaiApiKey,
    this.openaiEmbeddingsModel,
    this.visionProvider,
    this.visionModel,
    this.vectorDbUrl,
    this.vectorDbApiKey,
    this.vectorDbIndex,
    this.googleMapsApiKey,
  });

  /// Supabase project URL.
  final String supabaseUrl;

  /// Supabase anonymous key allowing client-side access with RLS.
  final String supabaseAnonKey;

  /// Preferred LLM provider (e.g. openai, anthropic).
  final String? llmProvider;
  final String? openaiApiKey;
  final String? openaiEmbeddingsModel;

  /// Vision service configuration.
  final String? visionProvider;
  final String? visionModel;

  /// Optional vector database configuration for demos.
  final String? vectorDbUrl;
  final String? vectorDbApiKey;
  final String? vectorDbIndex;

  /// Google Maps key for lifestyle integrations.
  final String? googleMapsApiKey;

  /// Creates an [AppConfig] reading from the current process environment.
  factory AppConfig.fromEnv() {
    final env = Platform.environment;
    return AppConfig(
      supabaseUrl: env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: env['SUPABASE_ANON_KEY'] ?? '',
      llmProvider: env['LLM_PROVIDER'],
      openaiApiKey: env['OPENAI_API_KEY'],
      openaiEmbeddingsModel: env['OPENAI_EMBEDDINGS_MODEL'],
      visionProvider: env['VISION_PROVIDER'],
      visionModel: env['VISION_MODEL'],
      vectorDbUrl: env['VECTOR_DB_URL'],
      vectorDbApiKey: env['VECTOR_DB_API_KEY'],
      vectorDbIndex: env['VECTOR_DB_INDEX'],
      googleMapsApiKey: env['GOOGLE_MAPS_API_KEY'],
    );
  }
}
