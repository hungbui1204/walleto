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

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: const BorderSide(),
              shadowColor: transParentColor,
              elevation: 0,
              backgroundColor:
                  key == S.current.clear || key == S.current.backspace
                      ? secondaryColor
                      : OperationType.values.map((e) => e.symbol).toList().contains(key) ||
                          key == S.current.equal ||
                          key == S.current.done
                      ? primaryColor
                      : primaryShade1Color,
              foregroundColor: blackColor,
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
              } else if (OperationType.values.map((e) => e.symbol).toList().contains(key)) {
                onOperatorKeyTap(key);
              } else {
                onNumberKeyTap(key);
              }
            },
            child: Text(key, style: AppTextStyles.s20wNormalBlack()),
          );
        },
      ),
    );
  }
}
