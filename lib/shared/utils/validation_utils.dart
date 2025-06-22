import 'package:walleto/shared/shared.dart';

class ValidationUtils {
  const ValidationUtils._();

  /// Check if a string is valid phone number.
  /// Return true if it is valid.
  static bool isValidPhoneNumber(String phoneNumber) {
    if (!RegexConstants.phoneNumber.hasMatch(phoneNumber.trim())) return false;

    return true;
  }

  /// Check if a string is a valid email.
  /// Return true if it is valid.
  static bool isValidEmail(String email) {
    if (!RegexConstants.email.hasMatch(email.trim())) return false;

    return true;
  }

  /// Check if a string is valid format password.
  /// Return true if it has at least 8 half-width alphanumeric characters, including uppercase letters, lowercase letters, and numbers.
  static bool isValidFormatPassword(String password) {
    if (!RegexConstants.password.hasMatch(password.trim())) return false;
    if (password.length < 8) return false;
    if (RegexConstants.space.hasMatch(password.trim())) return false;

    return true;
  }

  /// Check if a string has special character
  /// Return true if it has at least 1 special character
  static bool isHasSpecialCharacterInPassword(String password) {
    if (!RegexConstants.specialCharacter.hasMatch(password.trim())) return false;

    return true;
  }

  /// Check if a string is valid katakana characters.
  /// Return true if it is valid.
  static bool isValidKana(String kana) {
    if (!RegexConstants.kana.hasMatch(kana.trim())) return false;

    return true;
  }

  /// Check if a string is a valid date time.
  /// Return true if it is valid.
  static bool isValidDateTime(String dateTime) {
    if (!RegexConstants.dateTime.hasMatch(dateTime)) return false;

    return true;
  }

  /// Check if a string is alphanumeric.
  /// Return true if it is valid.
  static bool isAlphanumeric(String text) {
    if (!RegexConstants.alphaNumeric.hasMatch(text.trim())) return false;

    return true;
  }

  /// Check if string is link
  /// Return true if it is valid
  static bool isLink(String text) => Uri.parse(text).isAbsolute;

  /// Check if value is duplicate in the list value string
  static bool hasDuplicateValue(List<String> list) {
    if (list.isNotEmpty) {
      List<String> items = [list.first];

      for (var item in list) {
        if (!items.contains(item)) {
          return true;
        }

        items.add(item);
      }
    }

    return false;
  }
}
