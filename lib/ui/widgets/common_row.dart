import 'package:flutter/material.dart';

import 'common_amount_with_symbol.dart';
import 'common_list_row.dart';

class CommonRow extends StatelessWidget {
  const CommonRow({
    super.key,
    this.prefix,
    required this.title,
    required this.amount,
    required this.currencyCode,
    this.onTap,
    this.showChevron = false,
  });

  final Widget? prefix;
  final String title;
  final double amount;
  final String currencyCode;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return CommonListRow(
      leading: prefix,
      title: Text(title),
      trailing: CommonAmountWithSymbol(amount: amount, currencyCode: currencyCode),
      onTap: onTap,
      showChevron: showChevron,
      semanticLabel: title,
    );
  }
}
