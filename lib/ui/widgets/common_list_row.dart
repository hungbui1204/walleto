import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

import 'pressable.dart';

class CommonListRow extends StatelessWidget {
  const CommonListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.backgroundColor,
    this.semanticLabel,
    this.minHeight,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? backgroundColor;
  final String? semanticLabel;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final currentTitle = title;
    final resolvedTitle = _resolvedTitle(currentTitle);
    final label = semanticLabel ?? (currentTitle is Text ? currentTitle.data : null);
    final currentSubtitle = subtitle;

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? Dimens.d44.responsive()),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: Dimens.d10.responsive())],
          Expanded(
            child:
                currentSubtitle == null
                    ? resolvedTitle
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [resolvedTitle, currentSubtitle],
                    ),
          ),
          if (trailing != null) trailing!,
          if (showChevron) ...[
            if (trailing != null) SizedBox(width: Dimens.d4.responsive()),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: Dimens.d14.responsive(),
              color: darkGreyColor,
            ),
          ],
        ],
      ),
    );

    if (backgroundColor != null) {
      content = ColoredBox(color: backgroundColor!, child: content);
    }

    return Pressable(onTap: onTap, semanticLabel: label, child: content);
  }

  Widget _resolvedTitle(Widget currentTitle) {
    if (currentTitle is Text && currentTitle.style == null) {
      return DefaultTextStyle.merge(style: AppTextStyles.s16wNormalBlack(), child: currentTitle);
    }

    return currentTitle;
  }
}
