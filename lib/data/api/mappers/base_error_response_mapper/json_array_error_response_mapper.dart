
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonArrayErrorResponseMapper extends BaseErrorResponseMapper<List<dynamic>> {
  @override
  ServerError mapToServerError(List<dynamic>? errorResponse) {
    return ServerError(
      errors: errorResponse?.map((jsonObject) {
            return ServerErrorDetail(
              serverStatusCode: jsonObject['code'] as int?,
              message: jsonObject['message'] as String?,
            );
          }).toList(growable: false) ??
          [],
    );
  }
}
