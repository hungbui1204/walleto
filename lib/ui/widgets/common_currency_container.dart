import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

class CommonCurrencyContainer extends StatelessWidget {
  const CommonCurrencyContainer({super.key, this.currentCurrency});

  final Currency? currentCurrency;

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
      child: Center(child: Text(currentCurrency?.code ?? '', style: AppTextStyles.s14wBoldBlack())),
    );
  }
}
