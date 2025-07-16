import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  bool equalsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());

  String toHex() => toUtf8().map((e) => e.toRadixString(16)).toList().join();

  DateTime? toDateTime({String? format}) {
    if (isEmpty) return null;

    if (format != null && format.isNotEmpty) {
      final dateFormat = DateFormat(format);

      return dateFormat.tryParse(this);
    }

    return DateTime.tryParse(this);
  }

  int toInt() {
    if (isEmpty) return 0;

    // Remove commas if present, as they are not valid in integer parsing
    final cleanedString = replaceAll(',', '');

    final intValue = int.tryParse(cleanedString);
    if (intValue == null) {
      throw FormatException('Invalid integer format: $this');
    }

    return intValue;
  }

  int countAllNumbersLength() {
    // Match all numbers (digits with optional commas)
    final matches = RegExp(r'[\d,]+').allMatches(this);
    return matches.fold(0, (sum, match) => sum + match.group(0)!.replaceAll(',', '').length);
  }

  String toFormattedNumberString(NumberFormat formatter) {
    // Match individual numbers (digits with optional commas)
    // This will match each number separately, even when separated by operators
    return replaceAllMapped(RegExp(r'\b[\d,]+\b'), (match) {
      final numberStr = match.group(0)!;
      // Remove all commas first to get clean number
      final clean = numberStr.replaceAll(',', '');

      // Check if it's a valid number (only digits)
      if (!RegExp(r'^\d+$').hasMatch(clean)) {
        return numberStr; // Return original if not a valid number
      }

      final number = int.tryParse(clean);
      if (number == null) {
        return numberStr;
      }

      return formatter.format(number);
    });
  }
}
