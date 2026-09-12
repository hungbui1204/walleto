import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

enum PressableFeedback { scale, opacity, none }

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.semanticLabel,
    this.feedback = PressableFeedback.scale,
  });

  static const double pressedScale = 0.97;
  static const double pressedOpacity = 0.72;

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final PressableFeedback feedback;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    final onTap = widget.onTap;
    if (onTap == null) return;
    HapticFeedback.selectionClick();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final feedback = enabled ? widget.feedback : PressableFeedback.none;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : DurationConstants.microInteraction;
    final radius = widget.borderRadius ?? AppDecorations.panelRadius();
    final scale = feedback == PressableFeedback.scale && _pressed ? Pressable.pressedScale : 1.0;
    final opacity =
        feedback == PressableFeedback.opacity && _pressed ? Pressable.pressedOpacity : 1.0;

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        // Primitive detector for Pressable — not a product control.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _handleTap : null,
          onTapDown: enabled ? (_) => _setPressed(true) : null,
          onTapUp: enabled ? (_) => _setPressed(false) : null,
          onTapCancel: enabled ? () => _setPressed(false) : null,
          child: ClipRRect(
            borderRadius: radius,
            child: AnimatedScale(
              scale: scale,
              duration: duration,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: duration,
                curve: Curves.easeOut,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
