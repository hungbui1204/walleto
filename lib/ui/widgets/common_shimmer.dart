import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

/// Ancestor that owns a single [AnimationController] shared by descendant
/// shimmer primitives so they animate in sync.
class CommonShimmer extends StatefulWidget {
  const CommonShimmer({super.key, required this.child});

  final Widget child;

  static Animation<double>? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CommonShimmerScope>()?.animation;
  }

  @override
  State<CommonShimmer> createState() => _CommonShimmerState();
}

class _CommonShimmerState extends State<CommonShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DurationConstants.defaultShimmerDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CommonShimmerScope(animation: _controller, child: widget.child);
  }
}

class _CommonShimmerScope extends InheritedWidget {
  const _CommonShimmerScope({required this.animation, required super.child});

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_CommonShimmerScope oldWidget) => animation != oldWidget.animation;
}

/// Rounded placeholder block. Animates when under [CommonShimmer]; otherwise
/// renders a static [backgroundShimmer] box.
class CommonShimmerBox extends StatelessWidget {
  const CommonShimmerBox({super.key, this.width, this.height, this.borderRadius});

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? Dimens.d16.responsive();
    final boxHeight = height ?? Dimens.d16.responsive();
    final animation = CommonShimmer.maybeOf(context);

    if (animation == null) {
      return Container(
        width: width,
        height: boxHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: backgroundShimmer,
        ),
      );
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: boxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * animation.value, 0),
              end: Alignment(2 * animation.value, 0),
              colors: const [backgroundShimmer, backgroundShimmerHighlight, backgroundShimmer],
            ),
          ),
        );
      },
    );
  }
}

class CommonShimmerCircle extends StatelessWidget {
  const CommonShimmerCircle({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final diameter = size ?? Dimens.d36.responsive();

    return CommonShimmerBox(width: diameter, height: diameter, borderRadius: diameter / 2);
  }
}

class CommonShimmerListTile extends StatelessWidget {
  const CommonShimmerListTile({super.key, this.lineCount = 2, this.showTrailing = true});

  final int lineCount;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
      child: Row(
        children: [
          CommonShimmerCircle(size: Dimens.d36.responsive()),
          SizedBox(width: Dimens.d10.responsive()),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonShimmerBox(height: Dimens.d14.responsive(), width: Dimens.d120.responsive()),
                if (lineCount > 1) ...[
                  SizedBox(height: Dimens.d8.responsive()),
                  CommonShimmerBox(height: Dimens.d12.responsive(), width: Dimens.d80.responsive()),
                ],
              ],
            ),
          ),
          if (showTrailing) ...[
            SizedBox(width: Dimens.d10.responsive()),
            CommonShimmerBox(height: Dimens.d14.responsive(), width: Dimens.d56.responsive()),
          ],
        ],
      ),
    );
  }
}

/// Glass panel wrapping skeleton content, with an optional fake title bar.
class CommonShimmerPanel extends StatelessWidget {
  const CommonShimmerPanel({super.key, this.showTitleBar = true, this.title, required this.child});

  final bool showTitleBar;
  final Widget? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final titleBar =
        title ??
        (showTitleBar
            ? Align(
              alignment: Alignment.centerLeft,
              child: CommonShimmerBox(
                height: Dimens.d16.responsive(),
                width: Dimens.d120.responsive(),
              ),
            )
            : null);

    return Container(
      decoration: AppDecorations.glassPanel(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(Dimens.d16.responsive()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (titleBar != null) ...[titleBar, SizedBox(height: Dimens.d16.responsive())],
            child,
          ],
        ),
      ),
    );
  }
}
