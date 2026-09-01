import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(Dimens.d56.responsive());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transParentColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(title, style: AppTextStyles.s20wBoldBlack()),
      actions: actions,
    );
  }
}
