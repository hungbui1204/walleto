import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonContainer2 extends StatelessWidget {
  const CommonContainer2({
    super.key,
    this.padding,
    this.color,
    this.borderRadius,
    required this.child,
  });

  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? primaryShade1Color,
        borderRadius: BorderRadius.circular(borderRadius ?? Dimens.d10.responsive()),
        border: Border.all(),
      ),
      child: child,
    );
  }
}
