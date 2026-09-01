import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/extensions/operation_type_extension.dart';
import 'package:walleto/ui/utils/app_utils.dart';

enum TransactionAmountEvaluateError { empty, invalidFormat, tooLarge }

class TransactionAmountOperatorResult {
  const TransactionAmountOperatorResult({required this.amountInput, required this.operation});

  final String amountInput;
  final OperationType operation;
}

class TransactionAmountBackspaceResult {
  const TransactionAmountBackspaceResult({
    required this.amountInput,
    required this.clearedOperator,
  });

  final String amountInput;
  final bool clearedOperator;
}

class TransactionAmountEvaluateResult {
  const TransactionAmountEvaluateResult._({
    this.formattedAmount,
    this.error,
    this.unchanged = false,
  });

  factory TransactionAmountEvaluateResult.success(String formattedAmount) {
    return TransactionAmountEvaluateResult._(formattedAmount: formattedAmount);
  }

  factory TransactionAmountEvaluateResult.failure(TransactionAmountEvaluateError error) {
    return TransactionAmountEvaluateResult._(error: error);
  }

  factory TransactionAmountEvaluateResult.unchanged() {
    return const TransactionAmountEvaluateResult._(unchanged: true);
  }

  final String? formattedAmount;
  final TransactionAmountEvaluateError? error;
  final bool unchanged;
}

/// Shared amount keypad math for create and edit transaction blocs.
class TransactionAmountCalculator {
  const TransactionAmountCalculator._();

  static String format(String input) {
    return input.toFormattedNumberString(NumberFormatConstants.amountFormat);
  }

  static String formatAmount(double amount) {
    return amount.toStringWithFormat(NumberFormatConstants.amountFormat);
  }

  static bool exceedsMaxLength(String input) {
    return input.countAllNumbersLength() > AppConstants.maxTransactionAmountLength;
  }

  /// Appends a keypad number (`0` / `00` / `000` or a digit). Returns null if rejected.
  static String? appendNumber({required String currentInput, required String number}) {
    var newAmount = currentInput;
    if (newAmount.startsWith('0')) {
      newAmount = newAmount.substring(1);
    }

    if (newAmount.isEmpty && number.contains('0')) {
      return null;
    }

    newAmount += number;

    if (exceedsMaxLength(newAmount)) {
      return null;
    }

    return format(newAmount);
  }

  /// Appends a calculator operator. Returns null if an operator is already set or input is empty/`0`.
  static TransactionAmountOperatorResult? appendOperator({
    required String currentInput,
    required String operationSymbol,
    required OperationType? currentOperation,
  }) {
    if (currentOperation != null) {
      return null;
    }

    if (currentInput.isEmpty || currentInput == '0') {
      return null;
    }

    return TransactionAmountOperatorResult(
      amountInput: '$currentInput$operationSymbol',
      operation: OperationTypeExtension.fromString(operationSymbol),
    );
  }

  /// Removes the last character. Returns null when [currentInput] is empty.
  static TransactionAmountBackspaceResult? backspace(String currentInput) {
    if (currentInput.isEmpty) {
      return null;
    }

    final clearedOperator = AppUtils.isEndWithOperator(currentInput);
    final newAmount = currentInput.substring(0, currentInput.length - 1);

    return TransactionAmountBackspaceResult(
      amountInput: format(newAmount),
      clearedOperator: clearedOperator,
    );
  }

  static TransactionAmountEvaluateResult evaluate({
    required String currentInput,
    required OperationType? currentOperation,
  }) {
    if (currentInput.isEmpty) {
      return TransactionAmountEvaluateResult.failure(TransactionAmountEvaluateError.empty);
    }

    if (AppUtils.isEndWithOperator(currentInput)) {
      return TransactionAmountEvaluateResult.failure(TransactionAmountEvaluateError.invalidFormat);
    }

    if (currentOperation == null) {
      return TransactionAmountEvaluateResult.unchanged();
    }

    final amount = applyOperation(input: currentInput, operation: currentOperation);

    if (exceedsMaxLength(amount.toString())) {
      return TransactionAmountEvaluateResult.failure(TransactionAmountEvaluateError.tooLarge);
    }

    return TransactionAmountEvaluateResult.success(formatAmount(amount));
  }

  static double applyOperation({required String input, required OperationType operation}) {
    final operands = input.split(operation.symbol).map((e) => e.toDouble()).toList();

    return switch (operation) {
      OperationType.addition => operands.reduce((a, b) => a + b),
      OperationType.subtraction => operands.reduce((a, b) => a - b),
      OperationType.multiplication => operands.reduce((a, b) => a * b).roundTo2Digits(),
      OperationType.division => operands.reduce((a, b) => a / b).roundTo2Digits(),
    };
  }
}
