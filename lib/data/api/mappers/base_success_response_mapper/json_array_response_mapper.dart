import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class JsonArrayResponseMapper<T extends Object> extends BaseSuccessResponseMapper<T, List<T>> {
  @override
  List<T>? mapToDataModel({required dynamic response, Decoder<T>? decoder, int? statusCode}) {
    return decoder != null && response is List
        ? response
            .map((jsonObject) => decoder(jsonObject as Map<String, dynamic>))
            .toList(growable: false)
        : null;
  }
}
