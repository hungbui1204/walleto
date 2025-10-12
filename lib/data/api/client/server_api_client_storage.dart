import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class ServerApiClientStorage extends ApiClient {
  ServerApiClientStorage(HeaderInterceptor headerInterceptor, CookieInterceptor cookieInterceptor)
    : super(
        dio: DioBuilder.createDio(
          options: BaseOptions(baseUrl: UrlConstants.appApiBaseUrlStorage),
          interceptors: [headerInterceptor, cookieInterceptor],
        ),
      );
}
