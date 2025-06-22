import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class ArrayJsonArrayResponseMapper<T extends Object>
    extends BaseSuccessResponseMapper<T, List<List<T>>> {
  @override
  List<List<T>>? mapToDataModel({required dynamic response, Decoder<T>? decoder, int? statusCode}) {
    return decoder != null && response is List
        ? response
            .map((jsonList) {
              return (jsonList as List)
                  .map((jsonObject) => decoder(jsonObject as Map<String, dynamic>))
                  .toList(growable: false);
            })
            .toList(growable: false)
        : null;
  }
}
