import 'package:flutter/material.dart';
import 'package:walleto/shared/shared.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final scale = !enabled || !_pressed ? 1.0 : 0.97;

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: AnimatedScale(
            scale: scale,
            duration:
                reduceMotion
                    ? Duration.zero
                    : DurationConstants.microInteraction,
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
