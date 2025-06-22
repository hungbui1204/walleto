import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class ListJsonArrayResponseMapper<T extends Object>
    extends BaseSuccessResponseMapper<T, ListResponse<T>> {
  @override
  ListResponse<T>? mapToDataModel({
    required dynamic response,
    Decoder<T>? decoder,
    int? statusCode,
  }) {
    return decoder != null && response is Map<String, dynamic>
        ? ListResponse.fromJson(response, (json) => decoder(json))
        : null;
  }
}
