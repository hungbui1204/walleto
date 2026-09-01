import 'package:walleto/domain/domain.dart';

/// Calculator operator glyphs. Not i18n — keypad and amount parsing share these.
extension OperationTypeExtension on OperationType {
  static const additionSymbol = '+';
  static const subtractionSymbol = '-';
  static const multiplicationSymbol = '×';
  static const divisionSymbol = '÷';

  String get symbol {
    return switch (this) {
      OperationType.addition => additionSymbol,
      OperationType.subtraction => subtractionSymbol,
      OperationType.multiplication => multiplicationSymbol,
      OperationType.division => divisionSymbol,
    };
  }

  static OperationType fromString(String operation) {
    return switch (operation) {
      additionSymbol => OperationType.addition,
      subtractionSymbol => OperationType.subtraction,
      multiplicationSymbol => OperationType.multiplication,
      divisionSymbol => OperationType.division,
      _ => throw ArgumentError('Invalid operation type: $operation'),
    };
  }
}
