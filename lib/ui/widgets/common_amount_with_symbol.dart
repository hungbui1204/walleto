import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class CommonAmountWithSymbol extends StatelessWidget {
  const CommonAmountWithSymbol({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.textStyle,
  });

  final double amount;
  final String currencyCode;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          amount.toStringWithFormat(NumberFormatConstants.amountFormat),
          style: textStyle ?? AppTextStyles.s16wNormalBlack(),
        ),
        const SizedBox(width: 4),
        BlocBuilder<AppBloc, AppState>(
          buildWhen: (previous, current) => previous.currencies != current.currencies,
          builder: (context, state) {
            final currency = state.currencies.firstOrNullWhere((currency) {
              return currency.code == currencyCode;
            });

            if (currency == null) return const SizedBox.shrink();

            return Text(currency.symbol, style: textStyle ?? AppTextStyles.s16wNormalBlack());
          },
        ),
      ],
    );
  }
}
