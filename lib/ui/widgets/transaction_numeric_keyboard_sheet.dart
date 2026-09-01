import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/widgets/numeric_keyboard.dart';

class TransactionNumericKeyboardSheet extends StatelessWidget {
  const TransactionNumericKeyboardSheet({
    super.key,
    required this.visible,
    required this.onNumberKeyTap,
    required this.onOperatorKeyTap,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
    required this.onEqual,
  });

  final bool visible;
  final void Function(String) onNumberKeyTap;
  final void Function(String) onOperatorKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final VoidCallback onEqual;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: DurationConstants.defaultAnimationDuration,
      curve: Curves.easeOut,
      bottom: visible ? 0 : -Dimens.d400.responsive(),
      child: DecoratedBox(
        decoration: AppDecorations.keyboardSheet(),
        child: SafeArea(
          top: false,
          child: NumericKeyboard(
            onNumberKeyTap: onNumberKeyTap,
            onOperatorKeyTap: onOperatorKeyTap,
            onBackspace: onBackspace,
            onClear: onClear,
            onDone: onDone,
            onEqual: onEqual,
          ),
        ),
      ),
    );
  }
}
