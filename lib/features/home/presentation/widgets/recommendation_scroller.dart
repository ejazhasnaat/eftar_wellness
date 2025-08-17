import 'package:flutter/material.dart';

/// Horizontal list of recommended items for today.
class RecommendationScroller extends StatelessWidget {
  const RecommendationScroller({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const r = 14.0;

    final items = <String>[
      'High-protein vegetarian breakfasts',
      'Guide: beginner 20-min run',
      'Hydration myths debunked',
      'Sleep hygiene checklist',
      'Mindful eating in 3 steps',
      'Quick stretches for desk jobs',
    ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final title = items[i];
          return Container(
            width: 232,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: cs.outlineVariant),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [cs.primaryContainer, cs.secondaryContainer],
                    ),
                  ),
                  child: const Icon(Icons.menu_book_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          );
        },
      ),
    );
  }
}

