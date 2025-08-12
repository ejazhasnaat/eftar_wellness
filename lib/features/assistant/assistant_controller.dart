import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/feature_gate.dart';

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AsyncValue<void>>((ref) {
  final gate = ref.read(featureGateProvider);
  return AssistantController(gate);
});

class AssistantController extends StateNotifier<AsyncValue<void>> {
  final FeatureGate gate;
  AssistantController(this.gate) : super(const AsyncData(null));

  Future<bool> trySendMessage(String text) async {
    state = const AsyncLoading();
    await gate.refresh();
    final (ok, _) = await gate.canUseAssistant();
    if (!ok) { state = const AsyncData(null); return false; }

    // TODO: call your backend /assistant/query
    await Future.delayed(const Duration(milliseconds: 250)); // placeholder

    await gate.consumeAssistantTurn();
    state = const AsyncData(null);
    return true;
  }
}
