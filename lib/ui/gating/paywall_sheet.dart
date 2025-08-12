import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallSheet extends StatelessWidget {
  final String headline;
  final String body;
  final String ctaUrl;

  const PaywallSheet({super.key, required this.headline, required this.body, required this.ctaUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(headline, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(body),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => launchUrl(Uri.parse(ctaUrl), mode: LaunchMode.externalApplication),
              child: const Text('Go Premium'),
            ),
          ),
        ]),
      ),
    );
  }
}
