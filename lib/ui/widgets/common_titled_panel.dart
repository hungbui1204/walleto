import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

import 'common_line.dart';

class CommonTitledPanel extends StatelessWidget {
  const CommonTitledPanel({
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
      decoration: AppDecorations.glassPanel(color: titleBackgroundColor ?? surfaceColor),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (titleWidget != null)
            Padding(
              padding:
                  titlePadding ??
                  EdgeInsets.fromLTRB(
                    Dimens.d16.responsive(),
                    Dimens.d16.responsive(),
                    Dimens.d16.responsive(),
                    contentWidget == null ? Dimens.d16.responsive() : Dimens.d8.responsive(),
                  ),
              child: titleWidget,
            ),
          if (contentWidget != null)
            Padding(
              padding:
                  contentPadding ??
                  EdgeInsets.fromLTRB(
                    Dimens.d16.responsive(),
                    titleWidget == null ? Dimens.d16.responsive() : Dimens.d4.responsive(),
                    Dimens.d16.responsive(),
                    Dimens.d16.responsive(),
                  ),
              child: contentWidget,
            ),
        ],
      ),
    );
  }
}

class CommonTitledPanelSliver extends StatelessWidget {
  const CommonTitledPanelSliver({
    super.key,
    required this.titleWidget,
    required this.itemCount,
    required this.itemBuilder,
    this.titlePadding,
    this.contentPadding,
    this.titleBackgroundColor,
  });

  final Widget? titleWidget;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? titleBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedSliver(
      decoration: AppDecorations.glassPanel(color: titleBackgroundColor ?? surfaceColor),
      sliver: SliverMainAxisGroup(
        slivers: [
          if (titleWidget != null)
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    titlePadding ??
                    EdgeInsets.fromLTRB(
                      Dimens.d16.responsive(),
                      Dimens.d16.responsive(),
                      Dimens.d16.responsive(),
                      itemCount == 0 ? Dimens.d16.responsive() : Dimens.d8.responsive(),
                    ),
                child: titleWidget,
              ),
            ),
          if (itemCount > 0)
            SliverPadding(
              padding:
                  contentPadding ??
                  EdgeInsets.fromLTRB(
                    Dimens.d16.responsive(),
                    titleWidget == null ? Dimens.d16.responsive() : Dimens.d4.responsive(),
                    Dimens.d16.responsive(),
                    Dimens.d16.responsive(),
                  ),
              sliver: SliverList.separated(
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                separatorBuilder: (context, index) => const CommonLine(),
              ),
            ),
        ],
      ),
    );
  }
}
