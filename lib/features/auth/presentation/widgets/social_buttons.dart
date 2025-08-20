import 'package:flutter/material.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
    this.enabled = true,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: enabled ? onGoogle : null,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              shape: shape,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: cs.outline),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: enabled ? onApple : null,
            icon: const Icon(Icons.apple, size: 20),
            label: const Text('Continue with Apple'),
            style: OutlinedButton.styleFrom(
              shape: shape,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: cs.outline),
            ),
          ),
        ),
      ],
    );
  }
}
