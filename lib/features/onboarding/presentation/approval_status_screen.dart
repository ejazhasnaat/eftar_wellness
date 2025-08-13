import 'package:flutter/material.dart';

class ExpertApprovalStatusScreen extends StatelessWidget {
  const ExpertApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Submission status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_outlined, size: 48, color: cs.primary),
              const SizedBox(height: 12),
              Text('Your details are under review', style: tt.titleMedium),
              const SizedBox(height: 8),
              Text(
                'We’ll notify you once verification is complete.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

