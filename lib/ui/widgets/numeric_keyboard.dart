import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

import '../extensions/operation_type_extension.dart';
import 'pressable.dart';

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
      OperationType.division.symbol,
      '4',
      '5',
      '6',
      OperationType.multiplication.symbol,
      '1',
      '2',
      '3',
      OperationType.subtraction.symbol,
      '00',
      '0',
      '000',
      OperationType.addition.symbol,
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
          final isClearOrBackspace = key == S.current.clear || key == S.current.backspace;
          final isDone = key == S.current.done;
          final isOperator = operatorSymbols.contains(key) || key == S.current.equal;

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

          return _NumericKey(
            label: key,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            isPrimary: isDone,
            onTap: () {
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
          );
        },
      ),
    );
  }
}

class _NumericKey extends StatelessWidget {
  const _NumericKey({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    required this.isPrimary,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final radius = AppDecorations.chipRadius();

    return Pressable(
      onTap: onTap,
      borderRadius: radius,
      semanticLabel: label,
      child: DecoratedBox(
        decoration:
            isPrimary
                ? AppDecorations.primaryCta(radius: radius)
                : AppDecorations.secondaryCta(radius: radius, color: backgroundColor),
        child: Center(
          child: Text(
            label,
            style: AppThemes.amount(fontSize: Dimens.d18.responsive(), color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
