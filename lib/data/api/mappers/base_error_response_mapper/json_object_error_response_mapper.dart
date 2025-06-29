import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonObjectErrorResponseMapper extends BaseErrorResponseMapper<Map<String, dynamic>> {
  @override
  ServerError mapToServerError(Map<String, dynamic>? errorResponse) {
    if (errorResponse?['msg'] is List) {
      return ServerError(
        generalServerStatusCode: errorResponse?['code'] as int?,
        generalServerErrorId: errorResponse?['error_code'] as String?,
        generalMessage:
            (errorResponse?['msg'] as List?)?.isNotEmpty ?? false
                ? (errorResponse?['msg'] as List?)?.join('\n')
                : null,
      );
    }

    return ServerError(
      generalServerStatusCode: errorResponse?['code'] as int?,
      generalServerErrorId: errorResponse?['error_code'] as String?,
      generalMessage: errorResponse?['msg'] as String?,
    );
  }
}
