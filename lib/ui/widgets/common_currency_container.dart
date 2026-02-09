import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonCurrencyContainer extends StatelessWidget {
  const CommonCurrencyContainer({super.key, this.currentCurrencyCode});

  final String? currentCurrencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.d30.responsive(),
      width: Dimens.d40.responsive(),
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(),
        borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
      ),
      child: Center(child: Text(currentCurrencyCode ?? '', style: AppTextStyles.s14wBoldBlack())),
    );
  }
}
