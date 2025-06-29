extension NumberExtensions on int {
  DateTime? toDateTime() {
    if (this <= 0) return null;

    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    if (dateTime.isBefore(DateTime(1970))) {
      throw FormatException('Invalid timestamp: $this');
    }

    return dateTime;
  }
}
