import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ErrorWithRetryPopup extends PopUpWidget {
  ErrorWithRetryPopup({
    super.key,
    required super.message,
    this.errorAction,
    this.onRetryPressed,
  }) : super(
          icon: const _ErrorIcon(),
          action: errorAction ?? _ErrorButton(onRetryPressed: onRetryPressed),
        );

  final Widget? errorAction;
  final Func0<void>? onRetryPressed;
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
  const _ErrorButton({this.onRetryPressed});

  final Func0<void>? onRetryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ButtonWidget(
        //   text: S.current.retry,
        //   width: Dimens.d160.responsive(),
        //   isShowEndIcon: false,
        //   buttonSize: ButtonSize.small,
        //   buttonColor: ButtonColor.white,
        //   onPressed: onRetryPressed?.call ??
        //       () {
        //         getIt.get<AppNavigator>().pop(useRootNavigator: true);
        //       },
        // ),
        SizedBox(height: Dimens.d18.responsive()),
        // LinkWidget(
        //   text: S.current.cancel,
        //   textStyle: AppTextStyles.s16wBoldBlack().copyWith(height: 1),
        //   padding: EdgeInsets.all(Dimens.d8.responsive()),
        //   onTap: () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
        // ),
      ],
    );
  }
}
