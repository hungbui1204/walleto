import 'package:dartx/dartx.dart';

class ErrorCodeConstants {
  static Map<String, String> errorMessages = {
  };

  static String getErrorMessage(String errorCode) {
    return errorMessages[errorCode] ?? '';
  }

  static String? getKey(String errorCode) {
    return errorMessages.keys.firstOrNullWhere((key) => key == errorCode);
  }
}
