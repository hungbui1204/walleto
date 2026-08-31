import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class WarningPopup extends PopUpWidget {
  const WarningPopup({super.key, required super.content})
    : super(icon: const _WarningIcon(), action: const SizedBox.shrink());
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: Dimens.d64.responsive(),
          height: Dimens.d64.responsive(),
          decoration: BoxDecoration(border: Border.all(color: iconYellow), shape: BoxShape.circle),
        ),
        Icon(Icons.priority_high_rounded, size: Dimens.d34.responsive(), color: iconYellow),
      ],
    );
  }
}
