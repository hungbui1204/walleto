import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class BottomBarIconButton extends StatelessWidget {
  const BottomBarIconButton({super.key, required this.icon, required this.onTap});

  final void Function() onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: primaryShade1Color,
      onPressed: onTap,
      icon: icon,
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(Dimens.d12.responsive()),
      ),
    );
  }
}
