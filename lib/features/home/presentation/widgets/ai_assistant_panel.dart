import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

/// Displays a full-screen glassmorphism panel for the AI assistant.
Future<void> showAiAssistantPanel(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final barrierColor =
      isDark ? Colors.black.withOpacity(0.55) : Colors.white.withOpacity(0.7);

  return showGeneralDialog(
    context: context,
    barrierLabel: 'ai-panel',
    barrierDismissible: true,
    barrierColor: barrierColor,
    pageBuilder: (context, anim1, anim2) {
      return _AiAssistantPanel(onClose: () => Navigator.of(context).maybePop());
    },
    transitionBuilder: (context, anim, __, child) {
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(opacity: fade, child: child);
    },
    transitionDuration: const Duration(milliseconds: 260),
  );
}

class _AiAssistantPanel extends StatelessWidget {
  const _AiAssistantPanel({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        (isDark ? Colors.black : Colors.white).withOpacity(0.18);
    final borderColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.28);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'AI Wellness Assistant',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _AssistantSearchRow(height: 48.0, r: AppTheme.kOutlineRadius),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: const [
                      _SuggestionTile(
                        icon: Icons.checklist_rtl,
                        label: 'Plan my day',
                      ),
                      _SuggestionTile(
                        icon: Icons.tips_and_updates_outlined,
                        label: 'Personalized tips',
                      ),
                      _SuggestionTile(
                        icon: Icons.self_improvement,
                        label: 'Mindfulness exercises',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                heroTag: '_ai_close',
                onPressed: onClose,
                child: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Copied search box row styling from home screen
class _AssistantSearchRow extends StatelessWidget {
  const _AssistantSearchRow({required this.height, required this.r});
  final double height;
  final double r;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.kFillGrey,
                borderRadius: BorderRadius.circular(r),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.kSoftShadow,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border.all(color: cs.outlineVariant),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(r),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ask anything…',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: height,
            width: height,
            child: FloatingActionButton.small(
              heroTag: '_ai_mic',
              onPressed: () {},
              tooltip: 'Mic',
              child: const Icon(Icons.mic_none),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {},
    );
  }
}

