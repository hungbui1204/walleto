import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

/// Dark OLED empty placeholder — icon + muted copy, optional CTA.
class CommonEmptyPanel extends StatelessWidget {
  const CommonEmptyPanel({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final verticalPadding =
        compact ? Dimens.d16.responsive() : Dimens.d32.responsive();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: Dimens.d40.responsive(), color: darkGreyColor),
          SizedBox(height: Dimens.d12.responsive()),
          Text(
            message,
            style: AppTextStyles.s14wNormalGrey(),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: Dimens.d16.responsive()),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                minimumSize: Size(
                  Dimens.d44.responsive(),
                  Dimens.d44.responsive(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.d16.responsive(),
                ),
              ),
              child: Text(
                actionLabel!,
                style: AppTextStyles.s14wBoldBlack().copyWith(
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
