import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class AppUtils {
  const AppUtils._();

  static bool isEndWithOperator(String input) {
    return OperationType.values.map((e) => e.symbol).toList().any((element) {
      return element.equalsIgnoreCase(input[input.length - 1]);
    });
  }

  static bool isContainOperator(String input) {
    return OperationType.values.map((e) => e.symbol).toList().any((element) {
      return input.contains(element);
    });
  }
}
