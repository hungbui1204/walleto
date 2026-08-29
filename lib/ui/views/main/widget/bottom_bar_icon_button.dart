import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class BottomBarIconButton extends StatelessWidget {
  const BottomBarIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final VoidCallback onTap;
  final Widget icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: primaryShade1Color,
      highlightColor: primaryShade1Color,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(height: Dimens.d4.responsive()),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (selected
                      ? AppTextStyles.s10wBoldBlack()
                      : AppTextStyles.s10wNormalGrey())
                  .copyWith(color: selected ? primaryColor : darkGreyColor),
            ),
          ],
        ),
      ),
    );
  }
}
