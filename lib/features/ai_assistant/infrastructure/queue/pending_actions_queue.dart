// lib/features/ai_assistant/infrastructure/queue/pending_actions_queue.dart

import '../../domain/entities/intent.dart';

class PendingActionsQueue {
  final _queue = <Intent>[];

  void enqueue(Intent intent) => _queue.add(intent);

  List<Intent> get pending => List.unmodifiable(_queue);

  void clear() => _queue.clear();
}
