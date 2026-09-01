import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

extension TargetMonthExtension on TargetMonth {
  String get displayName {
    return switch (this) {
      TargetMonth.current => S.current.thisMonth,
      TargetMonth.previous => S.current.lastMonth,
    };
  }
}
