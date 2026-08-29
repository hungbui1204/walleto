import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AccentRule extends StatelessWidget {
  const AccentRule({super.key, this.width});

  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? Dimens.d48.responsive(),
      height: Dimens.d3.responsive(),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(Dimens.d2.responsive()),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.45),
            blurRadius: Dimens.d12.responsive(),
          ),
        ],
      ),
    );
  }
}
