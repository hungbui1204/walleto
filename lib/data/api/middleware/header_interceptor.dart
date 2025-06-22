import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'base_interceptor.dart';

@injectable
class HeaderInterceptor extends BaseInterceptor {
  HeaderInterceptor();

  Map<String, dynamic> _headers = {'X-Requested-With': 'dummy'};

  @override
  int get priority => BaseInterceptor.headerPriority;

  set headers(Map<String, dynamic> headers) {
    _headers = headers;
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll(_headers);

    handler.next(options);
  }
}
