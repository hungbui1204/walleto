import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonObjectErrorResponseMapper extends BaseErrorResponseMapper<Map<String, dynamic>> {
  @override
  ServerError mapToServerError(Map<String, dynamic>? errorResponse) {
    if (errorResponse?['message'] is List) {
      return ServerError(
        generalServerStatusCode: errorResponse?['status_code'] as int?,
        generalServerErrorId: errorResponse?['error_code'] as String?,
        generalMessage: (errorResponse?['message'] as List?)?.isNotEmpty ?? false
            ? (errorResponse?['message'] as List?)?.join('\n')
            : null,
      );
    }

    return ServerError(
      generalServerStatusCode: errorResponse?['status_code'] as int?,
      generalServerErrorId: errorResponse?['error_code'] as String?,
      generalMessage: errorResponse?['message'] as String?,
    );
  }
}
