import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CommonContainer extends StatelessWidget {
  const CommonContainer({
    super.key,
    required this.titleWidget,
    required this.contentWidget,
    this.titlePadding,
    this.titleBackgroundColor,
    this.contentPadding,
  });

  final Widget? titleWidget;
  final Widget? contentWidget;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? titleBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
        border: Border.all(),
      ),
      child: Column(
        children: [
          Container(
            padding: titlePadding ?? EdgeInsets.all(Dimens.d10.responsive()),
            decoration: BoxDecoration(
              color: titleBackgroundColor ?? primaryShade1Color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimens.d12.responsive()),
                topRight: Radius.circular(Dimens.d12.responsive()),
              ),
            ),
            child: titleWidget,
          ),
          const CommonLine(margin: EdgeInsets.zero),
          Padding(
            padding: contentPadding ?? EdgeInsets.all(Dimens.d10.responsive()),
            child: contentWidget,
          ),
        ],
      ),
    );
  }
}
