import 'package:flutter/material.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGoogle,
            icon: const Icon(Icons.g_mobiledata, size: 28), // simple placeholder icon
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              shape: shape,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: cs.outline),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onApple,
            icon: const Icon(Icons.apple, size: 20),
            label: const Text('Apple'),
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

