import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:walleto/data/data.dart';

class ApiClientDefaultSetting {
  const ApiClientDefaultSetting._();

  static const defaultSuccessResponseMapperType = SuccessResponseMapperType.jsonObject;
  static const defaultErrorResponseMapperType = ErrorResponseMapperType.jsonObject;

  // required interceptors
  static List<Interceptor> requiredInterceptors(Dio dio) {
    return [
      if (kDebugMode) CustomLogInterceptor(),
      ConnectivityInterceptor(),
      RetryOnErrorInterceptor(dio),
    ];
  }
}
