// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eftar_wellness/app/theme/theme_controller.dart';
import 'package:eftar_wellness/core/dev/reset_utils.dart';
import 'package:eftar_wellness/features/profile/presentation/health_info_settings_tile.dart';
import 'package:eftar_wellness/features/auth/application/auth_controller.dart';

/// App Settings (Profile → Settings).
/// Canonical settings screen (use this one in routes).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Account'),
          // Health Info editor → review screen with per-section edit buttons
          const HealthInfoSettingsTile(),
          const SizedBox(height: 12),

          const _SectionLabel('Preferences'),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: mode == ThemeMode.dark,
            onChanged: (v) => ref
                .read(themeModeProvider.notifier)
                .set(v ? ThemeMode.dark : ThemeMode.light),
          ),
          _Tile(
            leading: const Icon(Icons.notifications_outlined),
            title: 'Notifications',
            subtitle: 'Reminders & alerts',
            onTap: () => context.push('/settings/notifications'),
          ),
          const SizedBox(height: 12),

          const _SectionLabel('Privacy & Security'),
          _Tile(
            leading: const Icon(Icons.lock_outline),
            title: 'Privacy',
            subtitle: 'Permissions & data usage',
            onTap: () => context.push('/settings/privacy'),
          ),
          _Tile(
            leading: const Icon(Icons.security_outlined),
            title: 'Security',
            subtitle: 'Change password, 2FA',
            onTap: () => context.push('/settings/security'),
          ),
          const SizedBox(height: 24),

          // Developer / Debug — reset actions.
          const _SectionLabel('Developer'),
          _Tile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: 'Reset app (DB + preferences)',
            subtitle: 'Factory reset: clears local DB and SharedPreferences',
            onTap: () async {
              await ResetUtils.resetAll(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App reset complete')),
                );
              }
            },
          ),
          _Tile(
            leading: const Icon(Icons.storage_outlined),
            title: 'Delete local database only',
            subtitle: 'Remove eftar.db from app documents directory',
            onTap: () async {
              await ResetUtils.deleteDb(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local DB deleted')),
                );
              }
            },
          ),
          _Tile(
            leading: const Icon(Icons.settings_backup_restore_outlined),
            title: 'Clear preferences only',
            subtitle: 'SharedPreferences (sign-in state, simple settings)',
            onTap: () async {
              await ResetUtils.clearPrefs();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences cleared')),
                );
              }
            },
          ),

          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider).signOut();
              if (context.mounted) {
                context.go('/auth/signin');
              }
            },
            label: const Text('Sign out'),
          ),
          const SizedBox(height: 8),
          Text(
            'You can edit Health Info anytime from here.',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: theme.dividerColor),
      borderRadius: BorderRadius.circular(12),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: ShapeDecoration(
        color: Colors.transparent, // no fill; consistent with inputs
        shape: border,
      ),
      child: ListTile(
        leading: leading,
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
