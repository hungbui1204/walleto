import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toStringWithFormat(String format) => DateFormat(format).format(this);
}
