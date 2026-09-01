import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class TransactionAmountInput extends StatelessWidget {
  const TransactionAmountInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.amountInput,
    required this.amountError,
    required this.onTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String amountInput;
  final String amountError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          focusNode: focusNode,
          cursorHeight: Dimens.d28.responsive(),
          readOnly: true,
          showCursor: true,
          cursorColor: primaryColor,
          style: AppThemes.amount(fontSize: Dimens.d32.responsive(), color: primaryColor),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            counter: SizedBox.shrink(),
          ),
          onTap: onTap,
          controller: controller..text = amountInput,
        ),
        if (amountError.isNotEmpty) Text(amountError, style: AppTextStyles.s14wNormalRed()),
      ],
    );
  }
}
