import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class PopUpWidget extends StatelessWidget {
  const PopUpWidget({
    super.key,
    this.message,
    this.content,
    this.icon,
    this.action,
    this.contentPadding,
    this.actionPadding,
  }) : assert(message != null || content != null);

  final Widget? icon;
  final Widget? action;
  final String? message;
  final Widget? content;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionPadding;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      iconPadding: EdgeInsets.symmetric(
        horizontal: Dimens.d24.responsive(),
        vertical: Dimens.d40.responsive(),
      ).copyWith(bottom: Dimens.d24.responsive()),
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(horizontal: Dimens.d24.responsive()).copyWith(
            bottom: Dimens.d24.responsive(),
            top: icon == null ? Dimens.d40.responsive() : 0,
          ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: Dimens.d37.responsive(),
        vertical: Dimens.d40.responsive(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding:
          action is SizedBox
              ? EdgeInsets.zero
              : actionPadding ??
                  EdgeInsets.symmetric(
                    horizontal: Dimens.d24.responsive(),
                    vertical: Dimens.d40.responsive(),
                  ).copyWith(top: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.d8.responsive())),
      icon: icon,
      content: SizedBox(
        width: context.sizeOf.width,
        child:
            message != null
                ? Text(message!, style: AppTextStyles.s16wBoldBlack(), textAlign: TextAlign.center)
                : content,
      ),
      actions: [
        action ?? SizedBox.shrink(),
        // ButtonWidget(
        //   text: S.current.ok,
        //   onPressed: () => getIt.get<AppNavigator>().pop(useRootNavigator: true),
        // ),
      ],
    );
  }
}
