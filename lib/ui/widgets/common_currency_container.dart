import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class CommonCurrencyContainer extends StatelessWidget {
  const CommonCurrencyContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO Implement selecting currency logic

    return Container(
      height: Dimens.d30.responsive(),
      width: Dimens.d40.responsive(),
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(),
        borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
      ),
      child: Center(child: Text('VND', style: AppTextStyles.s14wBoldBlack())),
    );
  }
}
