import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonButton2 extends StatelessWidget {
  const CommonButton2({
    super.key,
    this.onTap,
    required this.text,
    this.padding,
    this.backgroundColor = whiteColor,
    this.icon,
    this.borderRadius,
    this.textStyle,
  });

  final VoidCallback? onTap;
  final String text;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Widget? icon;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius ?? BorderRadius.circular(Dimens.d8.responsive()),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d6.responsive()),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(Dimens.d8.responsive()),
          border: Border.all(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: Dimens.d8.responsive())],
            SizedBox(width: Dimens.d10.responsive()),
            Text(text, style: textStyle ?? AppTextStyles.s14wNormalBlack()),
          ],
        ),
      ),
    );
  }
}
