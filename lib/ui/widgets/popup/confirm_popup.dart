import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ConfirmPopup extends PopUpWidget {
  ConfirmPopup({
    super.key,
    super.icon,
    required super.message,
    this.confirmAction,
    this.onPressed,
    this.showCancel = false,
  }) : super(action: confirmAction ?? _ConfirmButton(onPressed: onPressed, showCancel: showCancel));

  final Widget? confirmAction;
  final Func0<void>? onPressed;
  final bool showCancel;
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({this.onPressed, this.showCancel = false});

  final Func0<void>? onPressed;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonButton(
          text: S.current.ok,
          onTap: onPressed?.call ?? () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
        ),
        if (showCancel) ...[
          SizedBox(height: Dimens.d18.responsive()),
          CommonButton(
            text: S.current.cancel,
            backgroundColor: secondaryColor,
            onTap: () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
          ),
        ],
      ],
    );
  }
}
