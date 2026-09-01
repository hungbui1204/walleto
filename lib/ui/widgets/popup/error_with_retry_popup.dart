import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ErrorWithRetryPopup extends PopUpWidget {
  ErrorWithRetryPopup({super.key, required super.message, this.errorAction, this.onRetryPressed})
    : super(
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
        Icon(Icons.close, size: Dimens.d34.responsive(), color: alertColor),
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
        CommonButton(
          text: S.current.retry,
          onTap:
              onRetryPressed?.call ??
              () => context.read<AppNavigator>().pop(useRootNavigator: true),
        ),
        SizedBox(height: Dimens.d18.responsive()),
        CommonButton(
          text: S.current.cancel,
          backgroundColor: surfaceColor,
          textColor: blackColor,
          onTap: () => context.read<AppNavigator>().pop(useRootNavigator: true),
        ),
      ],
    );
  }
}
