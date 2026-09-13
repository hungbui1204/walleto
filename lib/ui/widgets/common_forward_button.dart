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
    final radius = borderRadius ?? AppDecorations.panelRadius();

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
      child: Padding(
        padding: padding ?? EdgeInsets.all(Dimens.d12.responsive()),
        child: Row(
          children: [
            if (leadingIcon != null) ...[leadingIcon!, SizedBox(width: Dimens.d8.responsive())],
            Expanded(child: Text(title, style: AppTextStyles.s14wNormalBlack())),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Dimens.d14.responsive(),
              color: darkGreyColor,
            ),
          ],
        ),
      ),
    );

    if (showBorder) {
      content = DecoratedBox(
        decoration: AppDecorations.secondaryCta(radius: radius, color: color ?? transParentColor),
        child: content,
      );
    } else if (color != null) {
      content = ColoredBox(color: color!, child: content);
    }

    return Pressable(onTap: onTap, borderRadius: radius, semanticLabel: title, child: content);
  }
}
