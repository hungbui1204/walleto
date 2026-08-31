import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CompletePopup extends PopUpWidget {
  const CompletePopup({super.key, required super.message, this.completeAction})
    : super(icon: const _CompleteIcon(), action: completeAction ?? const SizedBox.shrink());

  final Widget? completeAction;
}

class _CompleteIcon extends StatelessWidget {
  const _CompleteIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: Dimens.d64.responsive(),
          height: Dimens.d64.responsive(),
          decoration: const BoxDecoration(color: accentGreen, shape: BoxShape.circle),
        ),
        Icon(Icons.check, size: Dimens.d34.responsive(), color: whiteColor),
      ],
    );
  }
}
