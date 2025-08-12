import 'package:flutter/material.dart';

typedef GateCheck = Future<(bool allowed, int remaining)> Function();

class GatedBuilder extends StatefulWidget {
  final GateCheck check;
  final VoidCallback onAllowed;
  final Widget child;
  final Widget Function(int remaining)? onBlocked;

  const GatedBuilder({
    super.key,
    required this.check,
    required this.onAllowed,
    required this.child,
    this.onBlocked,
  });

  @override
  State<GatedBuilder> createState() => _GatedBuilderState();
}

class _GatedBuilderState extends State<GatedBuilder> {
  bool _loading = false;

  Future<void> _tap() async {
    setState(() => _loading = true);
    final (ok, rem) = await widget.check();
    setState(() => _loading = false);
    if (ok) widget.onAllowed();
    else {
      if (widget.onBlocked != null) {
        showModalBottomSheet(context: context, builder: (_) => widget.onBlocked!(rem));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limit reached. Upgrade to continue.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _loading,
      child: InkWell(onTap: _tap, child: _loading ? const Center(child:CircularProgressIndicator()) : widget.child),
    );
  }
}
