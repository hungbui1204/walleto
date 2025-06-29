import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    this.onTap,
    required this.text,
    this.padding,
    this.borderRadius,
    this.backgroundColor = primaryColor,
    this.textColor = blackColor,
    this.icon,
  });

  final VoidCallback? onTap;
  final String text;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: whiteColor,
        backgroundColor: onTap != null ? backgroundColor : disableColor,
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: Dimens.d30, vertical: Dimens.d16.responsive()),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(Dimens.d30.responsive())),
          side: const BorderSide(),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: Dimens.d8.responsive())],
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
