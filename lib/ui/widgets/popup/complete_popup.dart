import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CompletePopup extends PopUpWidget {
  const CompletePopup({super.key, required super.message, this.completeAction})
    : super(icon: const _CompleteIcon(), action: completeAction ?? const _DismissButton());

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
        // Assets.icons.check01.svg(
        //   width: Dimens.d34.responsive(),
        //   height: Dimens.d34.responsive(),
        //   colorFilter: const ColorFilter.mode(whiteColor, BlendMode.srcIn),
        // ),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
    // ButtonWidget(
    //   text: S.current.dismiss,
    //   isShowEndIcon: false,
    //   buttonColor: ButtonColor.white,
    //   onPressed: () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
    // );
  }
}
