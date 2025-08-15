import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HealthInfoSettingsTile extends StatelessWidget {
  const HealthInfoSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.health_and_safety_outlined),
      title: const Text('Health Info'),
      subtitle: const Text('View or edit your body metrics, goals, and habits'),
      onTap: () => context.push('/settings/health-info'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

