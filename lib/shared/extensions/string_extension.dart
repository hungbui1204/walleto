import 'package:dartx/dartx.dart';
import 'package:intl/intl.dart';
import 'package:walleto/shared/shared.dart';

extension StringExtensions on String {
  bool equalsIgnoreCase(String secondString) => toLowerCase().contains(secondString.toLowerCase());

  /// English:
  /// Input 20241701
  /// Output 2024年17月01日
  ///
  /// Japanese:
  /// 入力 20241701
  /// 出力 2024年17月01日
  String formatDateNoSpaceToText() {
    if (length != 8) return this;

    final year = substring(0, 4);
    final month = substring(4, 6);
    final day = substring(6, 8);

    return '$year年$month月$day日';
  }

  /// English:
  /// Input: 20241701
  /// Output: 2024/17/01
  ///
  /// Japanese:
  /// 入力: 20241701
  /// 出力: 2024/17/01
  String formatDateNoSpaceToSlash() {
    if (length != 8) return this;

    final year = substring(0, 4);
    final month = substring(4, 6);
    final day = substring(6, 8);

    return '$year/$month/$day';
  }

  /// English:
  /// Input: 2024-17-01
  /// Output: 2024年17月01日
  ///
  /// Japanese:
  /// 入力: 2024-17-01
  /// 出力: 2024年17月01日
  String formatDateDashToText() {
    final date = split('-');

    final year = date[0];
    final month = date[1];
    final day = date[2];

    return '$year年$month月$day日';
  }

  String formatDateDashToTextWithJapaneseYear() {
    final date = split('-');

    final year = date[0].toInt().toJapaneseYear();
    final month = date[1];
    final day = date[2];

    return '$year$month月$day日';
  }

  /// English:
  /// Input: 2024年17月01日
  /// Output: 令和 7 年 17 月 01 日
  ///
  /// Japanese:
  /// 入力: 2024年17月01日
  /// 出力: 令和 7 年 17 月 01 日
  String formatDateTextToTextWithJapaneseYear() {
    final date = split('年');

    final year = date[0].toInt().toJapaneseYear();

    return '$year${date[1]}';
  }

  /// English:
  /// Input: 2024-04-22 15:24:36
  /// Output: 2024年04月22日 15:24:36
  ///
  /// Japanese:
  /// 入力: 2024-04-22 15:24:36
  /// 出力: 2024年04月22日 15:24:36
  String formatDateTime() {
    final date = DateTime.parse(this).toLocal();

    final year = date.year;
    final month = date.month;
    final day = date.day;

    final hours = date.hour;
    final minutes = date.minute;

    return '$year年$month月$day日 $hours:$minutes';
  }

  /// English:
  /// Input: 2025-04-08T15:11:08+09:00
  /// Output: 2025年04月08日
  ///
  /// Japanese:
  /// 入力: 2025-04-08T15:11:08+09:00
  /// 出力: 2025年04月08日
  String formatDate() {
    final date = DateTime.parse(this).toLocal();

    final year = date.year;
    final month = date.month;
    final day = date.day;

    return '$year年$month月$day日';
  }

  /// English:
  /// Input: 2025/03/11 19:39:10
  /// Output: 2025年03月11日 19:39:10
  ///
  /// Japanese:
  /// 入力: 2025/03/11 19:39:10
  /// 出力: 2025年03月11日 19:39:10
  String formatDateSlashTimeToDateTextTime() {
    final dateTime = split(' ');
    final date = dateTime[0].split('/');
    final time = dateTime[1].split(':');

    final year = date[0];
    final month = date[1];
    final day = date[2];

    final hours = time[0];
    final minutes = time[1];
    final seconds = time[2];

    return '$year年$month月$day日 $hours:$minutes:$seconds';
  }

  /// English:
  /// Input: 8100042
  /// Output: 810-0042
  ///
  /// Japanese:
  /// 入力: 8100042
  /// 出力: 810-0042
  String formatZipCode() {
    return replaceAllMapped(RegexConstants.zipCode, (match) => '${match[1]}-${match[2]}');
  }

  String toHex() => toUtf8().map((e) => e.toRadixString(16)).toList().join();

  /// English:
  ///
  /// Input: 2022年10月22日
  ///
  /// Output: DateTime(2022, 10, 22)
  ///
  /// Japanese
  ///
  /// 入力: 2022年10月22日
  ///
  /// 出力: DateTime(2022, 10, 22)
  DateTime? convertToJapanDateTime() {
    RegExp regex = RegexConstants.dateText;

    if (regex.hasMatch(this)) {
      return DateFormat(DateTimeFormatConstants.uiDateText).parse(this);
    }

    return null;
  }

  String convertDateFormat() {
    if (contains('年')) return this;

    late final int year;
    late final int month;
    late final int day;

    if (contains('/')) {
      final splitTargetDate = split('/');
      year = int.parse(splitTargetDate[0]);
      month = int.parse(splitTargetDate[1]);
      day = int.parse(splitTargetDate[2]);
    } else {
      final splitTargetDate = DateTime.parse(this);
      year = splitTargetDate.year;
      month = splitTargetDate.month;
      day = splitTargetDate.day;
    }

    return '$year年$month月$day日';
  }
}
