import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonObjectStatusCodeResponseMapper<T extends Object>
    extends BaseSuccessResponseMapper<T, StatusCodeResponse<T>> {
  @override
  StatusCodeResponse<T>? mapToDataModel({
    required dynamic response,
    Decoder<T>? decoder,
    int? statusCode,
  }) {
    return decoder != null
        ? response is Map<String, dynamic>
            ? StatusCodeResponse(data: decoder(response), statusCode: statusCode)
            : StatusCodeResponse(statusCode: statusCode)
        : StatusCodeResponse(statusCode: statusCode);
  }
}
