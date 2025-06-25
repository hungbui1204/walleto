import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class ServerApiClientAuth extends ApiClient {
  ServerApiClientAuth(HeaderInterceptor headerInterceptor, CookieInterceptor cookieInterceptor)
    : super(
        dio: DioBuilder.createDio(
          options: BaseOptions(baseUrl: UrlConstants.appApiBaseUrlAuth),
          interceptors: [headerInterceptor, cookieInterceptor],
        ),
      );
}
