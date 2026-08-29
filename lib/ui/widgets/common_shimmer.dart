import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

/// Dark OLED shimmer placeholder — uses [backgroundShimmer] tokens.
class CommonShimmerBox extends StatefulWidget {
  const CommonShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  State<CommonShimmerBox> createState() => _CommonShimmerBoxState();
}

class _CommonShimmerBoxState extends State<CommonShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? Dimens.d16.responsive();
    final height = widget.height ?? Dimens.d16.responsive();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(0 + 2 * _controller.value, 0),
              colors: const [
                backgroundShimmer,
                backgroundShimmerHighlight,
                backgroundShimmer,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton layout matching Home hero + chips + panels while data loads.
class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: Dimens.d8.responsive()),
              CommonShimmerBox(
                height: Dimens.d12.responsive(),
                width: Dimens.d80.responsive(),
              ),
              SizedBox(height: Dimens.d12.responsive()),
              CommonShimmerBox(height: Dimens.d40.responsive()),
              SizedBox(height: Dimens.d16.responsive()),
              Row(
                children: [
                  Expanded(
                    child: CommonShimmerBox(height: Dimens.d72.responsive()),
                  ),
                  SizedBox(width: Dimens.d12.responsive()),
                  Expanded(
                    child: CommonShimmerBox(height: Dimens.d72.responsive()),
                  ),
                ],
              ),
              SizedBox(height: Dimens.d16.responsive()),
              CommonShimmerBox(height: Dimens.d160.responsive()),
              SizedBox(height: Dimens.d16.responsive()),
              CommonShimmerBox(height: Dimens.d280.responsive()),
              SizedBox(height: Dimens.d16.responsive()),
              CommonShimmerBox(height: Dimens.d140.responsive()),
            ],
          ),
        ),
      ),
    );
  }
}
