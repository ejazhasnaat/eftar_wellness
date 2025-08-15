import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/health_info_settings_tile.dart';

/// App Settings (Profile → Settings).
/// Canonical settings screen (use this one in routes).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Account'),
          _Tile(
            leading: const Icon(Icons.person_outline),
            title: 'Profile',
            subtitle: 'Name, email, phone',
            onTap: () => context.push('/profile/edit'),
          ),
          // Health Info editor → review screen with per-section edit buttons
          const HealthInfoSettingsTile(),
          const SizedBox(height: 12),

          const _SectionLabel('Preferences'),
          _Tile(
            leading: const Icon(Icons.palette_outlined),
            title: 'Appearance',
            subtitle: 'Light / Dark / System',
            onTap: () => context.push('/settings/appearance'),
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

          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            onPressed: () => context.push('/signout'),
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

