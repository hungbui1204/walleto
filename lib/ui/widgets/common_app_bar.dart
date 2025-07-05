import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key, required this.title});

  final String title;

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(Dimens.d50.responsive());
}

class _CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryShadeColor,
      elevation: 0,
      title: Text(widget.title, style: AppTextStyles.s18wBoldBlack()),
      actions: [
        Assets.icons.search.svg(width: Dimens.d28.responsive(), height: Dimens.d28.responsive()),
        const SizedBox(width: Dimens.d20),
        Assets.icons.notice.svg(width: Dimens.d28.responsive(), height: Dimens.d28.responsive()),
        const SizedBox(width: Dimens.d10),
      ],
    );
  }
}
