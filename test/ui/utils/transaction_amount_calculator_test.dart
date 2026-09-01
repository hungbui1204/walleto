import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/extensions/operation_type_extension.dart';
import 'package:walleto/ui/utils/transaction_amount_calculator.dart';

void main() {
  String formatted(String input) {
    return input.toFormattedNumberString(NumberFormatConstants.amountFormat);
  }

  group('TransactionAmountCalculator.appendNumber', () {
    test('strips a leading zero then appends the digit', () {
      expect(TransactionAmountCalculator.appendNumber(currentInput: '0', number: '5'), '5');
    });

    test('rejects 0, 00, and 000 when the field is empty after stripping a leading zero', () {
      expect(TransactionAmountCalculator.appendNumber(currentInput: '0', number: '0'), isNull);
      expect(TransactionAmountCalculator.appendNumber(currentInput: '0', number: '00'), isNull);
      expect(TransactionAmountCalculator.appendNumber(currentInput: '0', number: '000'), isNull);
    });

    test('formats thousands separators while keeping an operator in place', () {
      expect(
        TransactionAmountCalculator.appendNumber(currentInput: '999', number: '9'),
        formatted('9999'),
      );
      expect(
        TransactionAmountCalculator.appendNumber(currentInput: '12+', number: '3'),
        formatted('12+3'),
      );
    });

    test('rejects input that would exceed maxTransactionAmountLength', () {
      final atLimit = '1' * AppConstants.maxTransactionAmountLength;
      final underLimit = '1' * (AppConstants.maxTransactionAmountLength - 1);

      expect(TransactionAmountCalculator.appendNumber(currentInput: atLimit, number: '1'), isNull);
      expect(
        TransactionAmountCalculator.appendNumber(currentInput: underLimit, number: '1'),
        formatted(atLimit),
      );
    });
  });

  group('TransactionAmountCalculator.appendOperator', () {
    test('appends + - × ÷ and maps the symbol to OperationType', () {
      final addition = TransactionAmountCalculator.appendOperator(
        currentInput: '12',
        operationSymbol: OperationType.addition.symbol,
        currentOperation: null,
      );
      expect(addition?.amountInput, '12${OperationType.addition.symbol}');
      expect(addition?.operation, OperationType.addition);

      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '12',
          operationSymbol: OperationType.subtraction.symbol,
          currentOperation: null,
        )?.operation,
        OperationType.subtraction,
      );
      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '12',
          operationSymbol: OperationType.multiplication.symbol,
          currentOperation: null,
        )?.operation,
        OperationType.multiplication,
      );
      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '12',
          operationSymbol: OperationType.division.symbol,
          currentOperation: null,
        )?.operation,
        OperationType.division,
      );
    });

    test('rejects a second operator, empty input, and a lone 0', () {
      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '12+',
          operationSymbol: OperationType.addition.symbol,
          currentOperation: OperationType.addition,
        ),
        isNull,
      );
      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '',
          operationSymbol: OperationType.addition.symbol,
          currentOperation: null,
        ),
        isNull,
      );
      expect(
        TransactionAmountCalculator.appendOperator(
          currentInput: '0',
          operationSymbol: OperationType.addition.symbol,
          currentOperation: null,
        ),
        isNull,
      );
    });
  });

  group('TransactionAmountCalculator.backspace', () {
    test('returns null when the field is empty', () {
      expect(TransactionAmountCalculator.backspace(''), isNull);
    });

    test('removes the last digit and reformats', () {
      final result = TransactionAmountCalculator.backspace(formatted('1234'));
      expect(result?.amountInput, formatted('123'));
      expect(result?.clearedOperator, isFalse);
    });

    test('clears the operator when the last character is one', () {
      final result = TransactionAmountCalculator.backspace('12${OperationType.addition.symbol}');
      expect(result?.amountInput, '12');
      expect(result?.clearedOperator, isTrue);
    });
  });

  group('TransactionAmountCalculator.applyOperation', () {
    test('splits on the operator and computes + - × ÷', () {
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '10${OperationType.addition.symbol}5',
          operation: OperationType.addition,
        ),
        15,
      );
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '10${OperationType.subtraction.symbol}3',
          operation: OperationType.subtraction,
        ),
        7,
      );
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '10${OperationType.multiplication.symbol}2',
          operation: OperationType.multiplication,
        ),
        20,
      );
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '10${OperationType.division.symbol}4',
          operation: OperationType.division,
        ),
        2.5,
      );
    });

    test('parses grouped operands and rounds × ÷ to 2 digits', () {
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '${formatted('1000')}${OperationType.addition.symbol}2',
          operation: OperationType.addition,
        ),
        1002,
      );
      expect(
        TransactionAmountCalculator.applyOperation(
          input: '10${OperationType.division.symbol}3',
          operation: OperationType.division,
        ),
        3.33,
      );
    });
  });

  group('TransactionAmountCalculator.evaluate', () {
    test('returns empty when the field is empty', () {
      final result = TransactionAmountCalculator.evaluate(
        currentInput: '',
        currentOperation: OperationType.addition,
      );
      expect(result.error, TransactionAmountEvaluateError.empty);
    });

    test('returns invalidFormat when the input ends with an operator', () {
      final result = TransactionAmountCalculator.evaluate(
        currentInput: '12${OperationType.addition.symbol}',
        currentOperation: OperationType.addition,
      );
      expect(result.error, TransactionAmountEvaluateError.invalidFormat);
    });

    test('returns unchanged when there is no pending operation', () {
      final result = TransactionAmountCalculator.evaluate(
        currentInput: '12',
        currentOperation: null,
      );
      expect(result.unchanged, isTrue);
      expect(result.formattedAmount, isNull);
    });

    test('formats a successful result and clears the pending operation at the caller', () {
      final result = TransactionAmountCalculator.evaluate(
        currentInput: '10${OperationType.addition.symbol}5',
        currentOperation: OperationType.addition,
      );
      expect(result.error, isNull);
      expect(result.formattedAmount, 15.toStringWithFormat(NumberFormatConstants.amountFormat));
    });

    test('returns tooLarge when the result exceeds maxTransactionAmountLength', () {
      final left = '9' * AppConstants.maxTransactionAmountLength;
      final result = TransactionAmountCalculator.evaluate(
        currentInput: '$left${OperationType.multiplication.symbol}9',
        currentOperation: OperationType.multiplication,
      );
      expect(result.error, TransactionAmountEvaluateError.tooLarge);
    });
  });
}
