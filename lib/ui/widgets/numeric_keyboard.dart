import 'package:flutter/material.dart';
import 'package:walleto/domain/entities/enum/enum.dart';
import 'package:walleto/resources/resources.dart';

class NumericKeyboard extends StatelessWidget {
  const NumericKeyboard({
    super.key,
    required this.onNumberKeyTap,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
    required this.onEqual,
    required this.onOperatorKeyTap,
  });

  final void Function(String) onNumberKeyTap;
  final void Function(String) onOperatorKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback onEqual;

  @override
  Widget build(BuildContext context) {
    final keys = [
      '7',
      '8',
      '9',
      S.current.division,
      '4',
      '5',
      '6',
      S.current.multiplication,
      '1',
      '2',
      '3',
      S.current.subtraction,
      '00',
      '0',
      '000',
      S.current.addition,
      S.current.clear,
      S.current.equal,
      S.current.backspace,
      S.current.done,
    ];

    final operatorSymbols = OperationType.values.map((e) => e.symbol).toList();

    return SizedBox(
      height: Dimens.d300.responsive(),
      width: Dimens.d390.responsive(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: Dimens.d6.responsive(),
          crossAxisSpacing: Dimens.d6.responsive(),
          childAspectRatio: 1.8,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.d12.responsive(),
          vertical: Dimens.d8.responsive(),
        ),
        itemBuilder: (context, index) {
          final key = keys[index];
          final isClearOrBackspace =
              key == S.current.clear || key == S.current.backspace;
          final isDone = key == S.current.done;
          final isOperator =
              operatorSymbols.contains(key) || key == S.current.equal;

          final Color backgroundColor;
          final Color foregroundColor;
          if (isDone) {
            backgroundColor = primaryColor;
            foregroundColor = onPrimaryColor;
          } else if (isOperator) {
            backgroundColor = primaryShadeColor;
            foregroundColor = primaryColor;
          } else if (isClearOrBackspace) {
            backgroundColor = fieldFillColor;
            foregroundColor = darkGreyColor;
          } else {
            backgroundColor = fieldFillColor;
            foregroundColor = blackColor;
          }

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: isDone ? primaryColor : glassHairlineColor,
              ),
              shadowColor: transParentColor,
              elevation: 0,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              minimumSize: Size(
                Dimens.d44.responsive(),
                Dimens.d44.responsive(),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
              ),
            ),
            onPressed: () {
              if (key == S.current.backspace) {
                onBackspace();
              } else if (key == S.current.clear) {
                onClear();
              } else if (key == S.current.done) {
                onDone();
              } else if (key == S.current.equal) {
                onEqual();
              } else if (operatorSymbols.contains(key)) {
                onOperatorKeyTap(key);
              } else {
                onNumberKeyTap(key);
              }
            },
            child: Text(
              key,
              style: AppThemes.amount(
                fontSize: Dimens.d18.responsive(),
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
