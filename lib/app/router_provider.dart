// lib/app/router_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eftar_wellness/app/router.dart';

/// Primary provider for the app router.
/// Returns the same router built in app/router.dart via buildRouter().
final routerProvider = Provider<GoRouter>((ref) => buildRouter());

/// Back-compat alias used by older code. Prefer [routerProvider] in new code.
@Deprecated('Use routerProvider instead')
final appRouterProvider = routerProvider;

