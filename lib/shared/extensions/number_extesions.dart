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

  String toCompactString() {
    if (this >= 1e12) {
      return '${(this / 1e12).toStringAsFixed(this % 1e12 == 0 ? 0 : 2)}T';
    } else if (this >= 1e9) {
      return '${(this / 1e9).toStringAsFixed(this % 1e9 == 0 ? 0 : 2)}B';
    } else if (this >= 1e6) {
      return '${(this / 1e6).toStringAsFixed(this % 1e6 == 0 ? 0 : 2)}M';
    } else if (this >= 1e3) {
      return '${(this / 1e3).toStringAsFixed(this % 1e3 == 0 ? 0 : 2)}K';
    } else {
      return toStringAsFixed(0);
    }
  }
}
