import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ErrorPopup extends PopUpWidget {
  const ErrorPopup({super.key, required super.message, this.errorAction})
    : super(icon: const _ErrorIcon(), action: errorAction ?? const _ErrorButton());

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
        // Assets.icons.close.svg(
        //   width: Dimens.d60.responsive(),
        //   height: Dimens.d60.responsive(),
        //   colorFilter: const ColorFilter.mode(alertColor, BlendMode.srcIn),
        // ),
      ],
    );
  }
}

class _ErrorButton extends StatelessWidget {
  const _ErrorButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
    // ButtonWidget(
    //   width: Dimens.d160.responsive(),
    //   text: S.current.dismiss,
    //   isShowEndIcon: false,
    //   buttonSize: ButtonSize.small,
    //   buttonColor: ButtonColor.white,
    //   onPressed: () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
    // );
  }
}
