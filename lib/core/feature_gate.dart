import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/subscription_repo.dart';
import '../data/usage_repo.dart';

class FeatureGate {
  final SubscriptionRepo subs;
  final UsageRepo usage;
  bool _premium = false;

  FeatureGate(this.subs, this.usage);

  bool get isPremium => _premium;

  Future<void> refresh() async { _premium = await subs.isPremium(); }

  Future<(bool allowed, int remaining)> canUseAssistant() =>
      usage.canUseAssistant(isPremium: _premium);

  Future<(bool allowed, int remaining)> canBookFreeAppointment() =>
      usage.canBookFreeAppointment(isPremium: _premium);

  Future<void> consumeAssistantTurn() => usage.increment('assistant_turn');
  Future<void> consumeFreeAppointment() => usage.increment('free_appointment');
}

final featureGateProvider = Provider<FeatureGate>((ref) {
  return FeatureGate(SubscriptionRepo(), UsageRepo());
});
