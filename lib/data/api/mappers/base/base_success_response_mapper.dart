import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

enum SuccessResponseMapperType {
  jsonObject,
  jsonArray,
  arrayJsonArray,
  listJsonArray,
  jsonObjectStatusCode,
}

abstract class BaseSuccessResponseMapper<I extends Object, O extends Object> {
  const BaseSuccessResponseMapper();

  factory BaseSuccessResponseMapper.fromType(SuccessResponseMapperType type) {
    return switch (type) {
      SuccessResponseMapperType.jsonObject =>
        JsonObjectResponseMapper<I>() as BaseSuccessResponseMapper<I, O>,
      SuccessResponseMapperType.jsonArray =>
        JsonArrayResponseMapper<I>() as BaseSuccessResponseMapper<I, O>,
      SuccessResponseMapperType.arrayJsonArray =>
        ArrayJsonArrayResponseMapper<I>() as BaseSuccessResponseMapper<I, O>,
      SuccessResponseMapperType.listJsonArray =>
        ListJsonArrayResponseMapper<I>() as BaseSuccessResponseMapper<I, O>,
      SuccessResponseMapperType.jsonObjectStatusCode =>
        JsonObjectStatusCodeResponseMapper<I>() as BaseSuccessResponseMapper<I, O>,
    };
  }

  O? map({required dynamic response, Decoder<I>? decoder, int? httpStatusCode}) {
    assert(response != null);

    if (httpStatusCode != null) {
      return mapToDataModel(response: response, decoder: decoder, statusCode: httpStatusCode);
    }

    return mapToDataModel(response: response, decoder: decoder);
  }

  O? mapToDataModel({required dynamic response, Decoder<I>? decoder, int? statusCode});
}
