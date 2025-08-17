import 'package:flutter/material.dart';

import '../../../../core/constants/feature_flags.dart';
import 'glass_panel.dart';

/// Row of assistant related shortcuts: Experts, AI Assistant and Scan Meal.
class AssistantRow extends StatelessWidget {
  const AssistantRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const r = 14.0;

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          // Experts card
          Expanded(
            child: Tooltip(
              message: 'Experts',
              child: InkWell(
                borderRadius: BorderRadius.circular(r),
                onTap: () => showGlassPanel(
                  context,
                  title: 'Experts',
                  actions: const [
                    GlassPanelAction(Icons.calendar_month, 'Book consultation'),
                    GlassPanelAction(Icons.medical_information, 'Dieticians & fitness coaches'),
                    GlassPanelAction(Icons.groups, 'Ask the community'),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(r),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.health_and_safety_outlined),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Experts',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // AI Assistant card
          Expanded(
            child: Tooltip(
              message: 'AI Assistant',
              child: InkWell(
                borderRadius: BorderRadius.circular(r),
                onTap: () => showGlassPanel(
                  context,
                  title: 'AI Assistant',
                  actions: [
                    const GlassPanelAction(Icons.chat_bubble_outline, 'Chat now'),
                    const GlassPanelAction(Icons.checklist_rtl, 'Plan my day'),
                    const GlassPanelAction(Icons.tips_and_updates_outlined, 'Personalized tips'),
                    if (FeatureFlags.aiAssistantVoice)
                      const GlassPanelAction(Icons.record_voice_over, 'Voice assistant'),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A980),
                    borderRadius: BorderRadius.circular(r),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.psychology_alt_outlined, color: Colors.white),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'AI Assistant',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Scan meal card
          Expanded(
            child: Tooltip(
              message: 'Scan Meal',
              child: InkWell(
                borderRadius: BorderRadius.circular(r),
                onTap: () => showGlassPanel(
                  context,
                  title: 'Scan Meal',
                  actions: const [
                    GlassPanelAction(Icons.document_scanner, 'Analyze meal photo'),
                    GlassPanelAction(Icons.local_fire_department_outlined, 'Calories & macros'),
                    GlassPanelAction(Icons.list_alt_outlined, 'Save to meal log'),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(r),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Scan Meal',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

