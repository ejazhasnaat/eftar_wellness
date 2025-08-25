import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/feature_flags.dart';
import '../../../../app/theme/app_theme.dart';
import '../widgets/assistant_row.dart';
import '../widgets/trackers_grid.dart';
import '../widgets/recommendation_scroller.dart';
import '../widgets/glass_panel.dart';
import '../../application/current_user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _r = AppTheme.kOutlineRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList.list(
              children: const [
                _CompactHeader(height: 60.0, r: _r),
                SizedBox(height: 8),
                _SearchRow(height: 48.0, r: _r),
                SizedBox(height: 10),
                _TodayPlanCard(height: 92.0, r: _r),
                SizedBox(height: 10),
                AssistantRow(),
                SizedBox(height: 12),
                _SectionHeader(title: 'Quick Actions & Trackers'),
                TrackersGrid(),
                SizedBox(height: 12),
                _SectionHeader(title: 'Explore'),
                _ExploreRow(r: _r),
                SizedBox(height: 12),
                _SectionHeader(title: 'Recommended for today'),
                RecommendationScroller(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '_ai_fab',
        tooltip: 'AI Wellness Assistant',
        onPressed: () => context.push('/assistant'),
        child: const Text(
          'AI',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(cs: cs),
    );
  }
}

/* ----------------------------- HEADER (compact) --------------------------- */

class _CompactHeader extends ConsumerWidget {
  const _CompactHeader({required this.height, required this.r});
  final double height;
  final double r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider).asData?.value;
    final name = user?.name.split(' ').first ?? 'there';

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Text(
            'Hi $name',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Inbox',
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => context.push('/profile/edit'),
            borderRadius: BorderRadius.circular(r),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Icon(
                Icons.person,
                color: cs.onPrimaryContainer,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ----------------------------- SEARCH + MIC ------------------------------- */

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.height, required this.r});
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Foods, plans, symptoms…',
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
              heroTag: '_micpill',
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

/* ----------------------------- TODAY PLAN CARD ---------------------------- */

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.height, required this.r});
  final double height;
  final double r;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _ProgressDonut(
                progress: 0.62,
                size: 56,
                bg: cs.surfaceContainerHighest,
                fg: Color(0xFF00A980),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s Plan',
                      style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3/5 done • Next: 20-min run 5 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              FilledButton(onPressed: () {}, child: const Text('Start')),
            ],
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- EXPLORE ROW -------------------------------- */

class _ExploreRow extends StatelessWidget {
  const _ExploreRow({required this.r});
  final double r;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final cards = <Widget>[
      _CategoryCard(
        r: r,
        title: 'Insights',
        icon: Icons.auto_awesome,
        gradientA: cs.secondaryContainer,
        gradientB: cs.tertiaryContainer,
        onTap: () => showGlassPanel(
          context,
          title: 'Insights',
          actions: const [
            GlassPanelAction(Icons.trending_up, 'Hydration streak +3'),
            GlassPanelAction(Icons.set_meal, 'Protein low yesterday'),
            GlassPanelAction(Icons.bedtime, 'Sleep 6h 20m'),
          ],
        ),
      ),
      _CategoryCard(
        r: r,
        title: 'Programs & Challenges',
        icon: Icons.flag_circle,
        gradientA: cs.primaryContainer,
        gradientB: cs.secondaryContainer,
        onTap: () => showGlassPanel(
          context,
          title: 'Programs & Challenges',
          actions: const [
            GlassPanelAction(Icons.run_circle, 'Beginner Run · 4w'),
            GlassPanelAction(Icons.monitor_heart, 'Cardio Boost · 3w'),
            GlassPanelAction(Icons.self_improvement, 'Mindful Sleep · 2w'),
          ],
        ),
      ),
    ];

    if (FeatureFlags.community) {
      cards.add(
        _CategoryCard(
          r: r,
          title: 'Community',
          icon: Icons.forum_outlined,
          gradientA: cs.surfaceContainerLowest,
          gradientB: cs.surfaceContainerLowest,
          onTap: () => showGlassPanel(
            context,
            title: 'Community',
            actions: const [
              GlassPanelAction(Icons.question_answer_outlined, 'Ask a question'),
              GlassPanelAction(Icons.thumb_up_alt_outlined, 'Give support'),
              GlassPanelAction(Icons.trending_up, 'Trending topics'),
            ],
          ),
        ),
      );
    }

    if (FeatureFlags.commerce) {
      cards.add(
        _CategoryCard(
          r: r,
          title: 'Marketplace',
          icon: Icons.shopping_bag_outlined,
          gradientA: cs.surfaceContainerLowest,
          gradientB: cs.surfaceContainerLowest,
          onTap: () => showGlassPanel(
            context,
            title: 'Marketplace',
            actions: const [
              GlassPanelAction(Icons.storefront, 'Browse products'),
              GlassPanelAction(Icons.local_offer_outlined, 'Deals & offers'),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i != cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.r,
    required this.title,
    required this.icon,
    required this.gradientA,
    required this.gradientB,
    required this.onTap,
  });
  final double r;
  final String title;
  final IconData icon;
  final Color gradientA;
  final Color gradientB;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isNeutral = gradientA == gradientB;
    return Tooltip(
      message: title,
      child: InkWell(
        borderRadius: BorderRadius.circular(r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: isNeutral
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientA, gradientB],
                  ),
            color: isNeutral ? gradientA : null,
            border: isNeutral
                ? Border.all(color: Theme.of(context).colorScheme.outlineVariant)
                : null,
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------- REUSABLE PIECES ------------------------------- */

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Text(title, style: t),
        const Spacer(),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ],
    );
  }
}

class _ProgressDonut extends StatelessWidget {
  const _ProgressDonut({
    required this.progress,
    required this.size,
    required this.bg,
    required this.fg,
  });
  final double progress;
  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            color: fg,
            backgroundColor: bg,
          ),
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Track',
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: cs.primaryContainer.withOpacity(0.6),
    );
  }
}

