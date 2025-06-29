import 'package:dartx/dartx.dart';

extension StringExtensions on String {
  bool equalsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());

  String toHex() => toUtf8().map((e) => e.toRadixString(16)).toList().join();

  DateTime? toDateTime() {
    if (isEmpty) return null;

    final dateTime = DateTime.tryParse(this);
    if (dateTime == null) {
      throw FormatException('Invalid date time format: $this');
    }

    return dateTime;
  }
}
