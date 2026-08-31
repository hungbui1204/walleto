import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ErrorPopup extends PopUpWidget {
  const ErrorPopup({super.key, required super.message, this.errorAction})
    : super(icon: const _ErrorIcon(), action: errorAction ?? const SizedBox.shrink());

  final Widget? errorAction;
}

class _ErrorIcon extends StatelessWidget {
  const _ErrorIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: Dimens.d64.responsive(),
          height: Dimens.d64.responsive(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: alertColor, width: Dimens.d4.responsive()),
          ),
        ),
        Icon(Icons.close, size: Dimens.d34.responsive(), color: alertColor),
      ],
    );
  }
}
