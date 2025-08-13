import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final controller = ref.read(themeModeProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme', style: tt.titleMedium),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('system'), icon: Icon(Icons.computer)),
                      ButtonSegment(value: ThemeMode.light,  label: Text('light'),  icon: Icon(Icons.wb_sunny_outlined)),
                      ButtonSegment(value: ThemeMode.dark,   label: Text('dark'),   icon: Icon(Icons.dark_mode_outlined)),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => controller.set(s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    themeMode == ThemeMode.system
                        ? 'Follows device setting'
                        : themeMode == ThemeMode.light ? 'Light mode' : 'Dark mode',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

