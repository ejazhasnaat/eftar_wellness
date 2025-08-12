import 'package:flutter/material.dart';
import 'challenge_repo.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}
class _ChallengesScreenState extends State<ChallengesScreen> {
  final repo = ChallengeRepo();
  List<Map<String,dynamic>> items = [];
  String? selectedId;
  List<Map<String,dynamic>> board = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async { items = await repo.active(); setState((){}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final c = items[i];
          return Card(
            child: ListTile(
              title: Text(c['name']),
              subtitle: Text('${c['goal_type']} • ${c['duration_days']} days'),
              trailing: FilledButton(
                onPressed: () async {
                  await repo.join(c['id']);
                  selectedId = c['id'];
                  board = await repo.leaderboard(selectedId!);
                  if (mounted) setState((){});
                },
                child: const Text('Join'),
              ),
              onTap: () async {
                selectedId = c['id'];
                board = await repo.leaderboard(selectedId!);
                setState((){});
              },
            ),
          );
        },
      ),
      bottomNavigationBar: selectedId == null ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ElevatedButton.icon(
              onPressed: () async {
                await repo.checkIn(selectedId!, DateTime.now());
                board = await repo.leaderboard(selectedId!);
                if (mounted) setState((){});
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Today Check-in'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: board.isEmpty ? const SizedBox() : SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: board.length,
                  itemBuilder: (_, i) => Chip(
                    label: Text('${i+1}. ${(board[i]['user_id'] as String).substring(0,6)} • ${board[i]['total_checkins']}'),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
