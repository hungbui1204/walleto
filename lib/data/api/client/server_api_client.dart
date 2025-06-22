import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

@LazySingleton()
class ServerApiClient extends ApiClient {
  ServerApiClient(
    HeaderInterceptor headerInterceptor,
    CookieInterceptor cookieInterceptor,
  ) : super(
          dio: DioBuilder.createDio(
            options: BaseOptions(baseUrl: UrlConstants.appApiBaseUrl),
            interceptors: [
              headerInterceptor,
              cookieInterceptor,
            ],
          ),
        );
}
