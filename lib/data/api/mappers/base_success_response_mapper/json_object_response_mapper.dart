import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonObjectResponseMapper<T extends Object> extends BaseSuccessResponseMapper<T, T> {
  @override
  T? mapToDataModel({required dynamic response, Decoder<T>? decoder, int? statusCode}) {
    return decoder != null && response is Map<String, dynamic> ? decoder(response) : null;
  }
}
