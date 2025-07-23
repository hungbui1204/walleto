import 'package:intl/intl.dart';

extension IntExtensions on int {
  DateTime? toDateTime() {
    if (this <= 0) return null;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    if (dateTime.isBefore(DateTime(1970))) {
      throw FormatException('Invalid timestamp: $this');
    }

    return dateTime;
  }
}

extension NumberExtensions on num {
  String toStringWithFormat(NumberFormat format) {
    return format.format(this);
  }

  double roundTo2Digits() {
    return double.parse(toStringAsFixed(2));
  }
}
