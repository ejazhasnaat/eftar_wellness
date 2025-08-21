// lib/features/ai_assistant/presentation/widgets/typing_indicator.dart

import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Dot(),
            _Dot(delay: 200),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({this.delay = 0});
  final int delay;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: DelayTween(begin: 0.2, end: 1, delay: widget.delay)
          .animate(_controller),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(width: 6, height: 6, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey))),
      ),
    );
  }
}

class DelayTween extends Tween<double> {
  DelayTween({required double begin, required double end, this.delay = 0})
      : super(begin: begin, end: end);

  final int delay;

  @override
  double lerp(double t) {
    final dt = (t + delay / 1000) % 1.0;
    return super.lerp(dt);
  }
}
