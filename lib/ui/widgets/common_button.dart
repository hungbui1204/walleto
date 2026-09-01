import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

import 'pressable.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    this.onTap,
    required this.text,
    this.padding,
    this.borderRadius,
    this.backgroundColor = primaryColor,
    this.textColor = onPrimaryColor,
    this.icon,
    this.compact = false,
  });

  final VoidCallback? onTap;
  final String text;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final radius = borderRadius ?? BorderRadius.all(Radius.circular(Dimens.d16.responsive()));
    final isPrimary = backgroundColor == primaryColor;
    final isDestructive = backgroundColor == redColor || textColor == redColor;

    final decoration =
        isPrimary
            ? (enabled
                ? AppDecorations.primaryCta(radius: radius)
                : AppDecorations.secondaryCta(radius: radius, color: frameColor))
            : AppDecorations.secondaryCta(
              radius: radius,
              color: backgroundColor ?? surfaceColor,
              borderColor: isDestructive ? redColor : glassHairlineColor,
            );

    final child = AnimatedOpacity(
      opacity: enabled ? 1 : 0.45,
      duration: DurationConstants.microInteraction,
      child: DecoratedBox(
        decoration: decoration,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: Dimens.d48.responsive(),
            minWidth: compact ? 0 : double.infinity,
          ),
          child: Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(
                  horizontal: Dimens.d20.responsive(),
                  vertical: Dimens.d14.responsive(),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (icon != null) ...[icon!, SizedBox(width: Dimens.d8.responsive())],
                if (compact)
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.s16wBoldBlack().copyWith(color: textColor),
                  )
                else
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.s16wBoldBlack().copyWith(color: textColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Pressable(onTap: onTap, borderRadius: radius, semanticLabel: text, child: child);
  }
}
