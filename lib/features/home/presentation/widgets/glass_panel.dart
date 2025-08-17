import 'dart:ui';
import 'package:flutter/material.dart';

/// Action shown inside a [GlassPanel].
class GlassPanelAction {
  final IconData icon;
  final String label;
  const GlassPanelAction(this.icon, this.label);
}

/// Displays a glassmorphism styled panel from the left side.
Future<void> showGlassPanel(
  BuildContext context, {
  required String title,
  required List<GlassPanelAction> actions,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'overlay',
    barrierColor: Colors.grey.withOpacity(0.55),
    barrierDismissible: true,
    pageBuilder: (context, anim1, anim2) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GlassPanel(
              widthFraction: 0.78,
              heightFraction: 0.6,
              title: title,
              actions: actions,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, anim, __, child) {
      final slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
    },
    transitionDuration: const Duration(milliseconds: 260),
  );
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.widthFraction,
    required this.heightFraction,
    required this.title,
    required this.actions,
    required this.onClose,
  });

  final double widthFraction;
  final double heightFraction;
  final String title;
  final List<GlassPanelAction> actions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width * widthFraction;
    final h = size.height * heightFraction;
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: w,
      height: h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final itemWidth = (w - 16 * 3) / 2;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: actions
                              .map((e) => SizedBox(
                                    width: itemWidth,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: cs.primaryContainer,
                                          child: Icon(e.icon, color: cs.onPrimaryContainer),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            e.label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

