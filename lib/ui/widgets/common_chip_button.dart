import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/widgets/pressable.dart';

class CommonChipButton extends StatelessWidget {
  const CommonChipButton({
    super.key,
    this.onTap,
    required this.text,
    this.padding,
    this.backgroundColor = surfaceColor,
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
    final radius =
        borderRadius ?? BorderRadius.circular(Dimens.d16.responsive());

    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      semanticLabel: text,
      child: Container(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: Dimens.d12.responsive(),
              vertical: Dimens.d8.responsive(),
            ),
        decoration: AppDecorations.secondaryCta(
          radius: radius,
          color: backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              SizedBox(width: Dimens.d8.responsive()),
            ],
            Flexible(
              child: Text(
                text,
                style: textStyle ?? AppTextStyles.s14wNormalBlack(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
