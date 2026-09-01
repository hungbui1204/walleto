import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class TargetMonthDataMapper extends BaseDataMapper<String, TargetMonth> {
  const TargetMonthDataMapper();

  @override
  TargetMonth mapToEntity(String? data) {
    return switch (data) {
      'this_month' => TargetMonth.current,
      'last_month' => TargetMonth.previous,
      _ => TargetMonth.current,
    };
  }
}
