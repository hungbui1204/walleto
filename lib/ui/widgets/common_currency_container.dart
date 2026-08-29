import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonCurrencyContainer extends StatelessWidget {
  const CommonCurrencyContainer({super.key, this.currentCurrencyCode});

  final String? currentCurrencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: Dimens.d44.responsive(),
        minWidth: Dimens.d48.responsive(),
      ),
      padding: EdgeInsets.symmetric(horizontal: Dimens.d8.responsive()),
      decoration: BoxDecoration(
        color: primaryShadeColor,
        border: Border.all(color: glassHairlineColor),
        borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
      ),
      alignment: Alignment.center,
      child: Text(
        currentCurrencyCode ?? '',
        style: AppThemes.amount(
          fontSize: Dimens.d14.responsive(),
          color: primaryColor,
        ),
      ),
    );
  }
}
