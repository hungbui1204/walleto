import 'package:walleto/shared/shared.dart';

abstract class ExceptionMapper<T extends AppException> {
  T map(Object? exception);
}
