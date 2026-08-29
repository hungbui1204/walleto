import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

/// Ambient OLED stage: deep scaffold + one soft teal blob (opacity ≤ 0.08).
class NoirBackdrop extends StatelessWidget {
  const NoirBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: scaffoldBackgroundColor),
          Positioned(
            top: -Dimens.d88.responsive(),
            right: -Dimens.d48.responsive(),
            child: _AmbientBlob(size: Dimens.d240.responsive(), opacity: 0.08),
          ),
          Positioned(
            bottom: Dimens.d96.responsive(),
            left: -Dimens.d72.responsive(),
            child: _AmbientBlob(size: Dimens.d200.responsive(), opacity: 0.05),
          ),
        ],
      ),
    );
  }
}

class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withValues(alpha: opacity),
      ),
    );
  }
}

/// Puts [NoirBackdrop] behind page content inside a [Scaffold] body.
class NoirScaffoldBody extends StatelessWidget {
  const NoirScaffoldBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [const NoirBackdrop(), child]);
  }
}
