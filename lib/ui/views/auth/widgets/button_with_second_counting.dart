import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/widgets/common_button.dart';

class ButtonWithSecondCounting extends StatelessWidget {
  const ButtonWithSecondCounting({
    super.key,
    this.count,
    required this.text,
    this.onTap,
    this.color,
  });

  final int? count;
  final String text;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isCounting = count != null && count! > 0;
    final background = color ?? primaryColor;
    final onColor =
        background == primaryColor || background == secondaryColor
            ? onPrimaryColor
            : blackColor;

    return Stack(
      children: [
        CommonButton(
          text: text,
          onTap: isCounting ? null : onTap,
          backgroundColor: background,
          textColor: onColor,
        ),
        if (isCounting)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(Dimens.d16.responsive()),
                ),
                color: scaffoldBackgroundColor.withValues(alpha: 0.55),
              ),
              alignment: Alignment.center,
              child: Text('$count', style: AppTextStyles.s16wBoldBlack()),
            ),
          ),
      ],
    );
  }
}
