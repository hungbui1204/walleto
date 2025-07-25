import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class TargetMonthDataMapper extends BaseDataMapper<String, TargetMonth> {
  const TargetMonthDataMapper();

  @override
  TargetMonth mapToEntity(String? data) {
    return TargetMonth.values.firstOrNullWhere((element) => element.name == data) ??
        TargetMonth.current;
  }
}
