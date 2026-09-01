import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

import 'pressable.dart';

class CommonForwardButton extends StatelessWidget {
  const CommonForwardButton({
    super.key,
    required this.title,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.color,
    this.leadingIcon,
    this.showBorder = true,
  });

  final String title;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Widget? leadingIcon;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(Dimens.d16.responsive());

    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      semanticLabel: title,
      child: Container(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        padding: padding ?? EdgeInsets.all(Dimens.d12.responsive()),
        decoration: BoxDecoration(
          color: color ?? transParentColor,
          borderRadius: radius,
          border: showBorder ? Border.all(color: glassHairlineColor) : null,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: Dimens.d8.responsive())],
            Expanded(child: Text(title, style: AppTextStyles.s14wNormalBlack())),
            Icon(Icons.arrow_forward_ios, size: Dimens.d14.responsive(), color: darkGreyColor),
          ],
        ),
      ),
    );
  }
}
