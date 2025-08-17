import 'package:flutter/material.dart';

/// Horizontally scrollable row of tracker cards (meals, hydration etc).
class TrackersGrid extends StatelessWidget {
  const TrackersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const r = 14.0;

    const trackers = <(IconData, String, String)>[
      (Icons.restaurant_menu, 'Meals', '2/3'),
      (Icons.local_drink, 'Hydration', '1200/2000ml'),
      (Icons.bedtime, 'Sleep', '6h 20m'),
      (Icons.directions_run, 'Activity', '4,100'),
    ];

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trackers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final t = trackers[i];
          return Container(
            width: 170,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(r),
              border: Border.all(color: cs.outlineVariant),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF00A980).withOpacity(0.15),
                  child: Icon(t.$1, color: const Color(0xFF00A980), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$2,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.$3,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

