import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../application/wellness_controller.dart';
import '../domain/models.dart';

class GoalsStepScreen extends ConsumerStatefulWidget {
  const GoalsStepScreen({super.key});
  @override
  ConsumerState<GoalsStepScreen> createState() => _GoalsStepScreenState();
}

class _GoalsStepScreenState extends ConsumerState<GoalsStepScreen> {
  final _otherGoalCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(wellnessProfileProvider);
    _otherGoalCtrl.text = s.goalOther ?? '';
  }

  @override
  void dispose() {
    _otherGoalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deco = theme.extension<AppDecorations>();
    final s = ref.watch(wellnessProfileProvider);
    final n = ref.read(wellnessProfileProvider.notifier);

    final isOther = s.goalPrimary == GoalPrimary.other;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health info • 2 of 2'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Goals & activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Tell us your main goal and your weekly activity. You can edit later.', style: theme.textTheme.bodyMedium),

          const SizedBox(height: 16),
          Container(
            decoration: deco?.outlinedTile(selected: false),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Primary goal', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Use Wrap of ChoiceChips to fit 5 options comfortably on mobile
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _goalChip(context, s, n, GoalPrimary.weightLoss, 'Weight loss'),
                    _goalChip(context, s, n, GoalPrimary.weightGain, 'Weight gain'),
                    _goalChip(context, s, n, GoalPrimary.stayFit, 'Stay fit'),
                    _goalChip(context, s, n, GoalPrimary.medicalManagement, 'Medical'),
                    _goalChip(context, s, n, GoalPrimary.other, 'Other'),
                  ],
                ),
                if (isOther) ...[
                  const SizedBox(height: 12),
                  Material(
                    elevation: 2,
                    shadowColor: AppTheme.kSoftShadow,
                    borderRadius: BorderRadius.circular(14),
                    child: TextFormField(
                      controller: _otherGoalCtrl,
                      decoration: const InputDecoration(labelText: 'Describe your goal'),
                      onChanged: (v) => n.setGoalOther(v.trim().isEmpty ? null : v.trim()),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            decoration: deco?.outlinedTile(selected: false),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly activity', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Cardio minutes per week (walking, cycling, running, etc.)',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: Material(
                      elevation: 2,
                      shadowColor: AppTheme.kSoftShadow,
                      borderRadius: BorderRadius.circular(14),
                      child: TextFormField(
                        initialValue: s.activity.minutesPerWeek.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cardio minutes/week'),
                        onChanged: (v) =>
                            n.setActivity(s.activity.copyWith(minutesPerWeek: int.tryParse(v.trim()) ?? 0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      elevation: 2,
                      shadowColor: AppTheme.kSoftShadow,
                      borderRadius: BorderRadius.circular(14),
                      child: TextFormField(
                        initialValue: s.activity.strengthDays.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Strength days/week'),
                        onChanged: (v) =>
                            n.setActivity(s.activity.copyWith(strengthDays: int.tryParse(v.trim()) ?? 0)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Material(
                  elevation: 2,
                  shadowColor: AppTheme.kSoftShadow,
                  borderRadius: BorderRadius.circular(14),
                  child: TextFormField(
                    initialValue: s.habits.hydrationCups.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Hydration (glasses/day)'),
                    onChanged: (v) {
                      final nCups = int.tryParse(v.trim()) ?? s.habits.hydrationCups;
                      n.setHabits(s.habits.copyWith(hydrationCups: nCups));
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => context.push('/onboard/wellness/review'),
                child: const Text('Next'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _goalChip(
    BuildContext context,
    UserWellnessProfile s,
    WellnessController n,
    GoalPrimary goal,
    String label,
  ) {
    final selected = s.goalPrimary == goal;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        n.setGoalPrimary(goal);
        if (goal != GoalPrimary.other) {
          n.setGoalOther(null);
        }
        setState(() {});
      },
    );
  }
}

