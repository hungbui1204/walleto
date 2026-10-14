import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/shared/shared.dart';

import 'base_interceptor.dart';

@injectable
class HeaderInterceptor extends BaseInterceptor {
  HeaderInterceptor(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  int get priority => BaseInterceptor.headerPriority;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final headers = await getHeaders();
    if (options.headers.containsKey('Authorization')) {
      headers.remove('Authorization');
    }
    if (options.headers.containsKey(ServerRequestResponseConstants.acceptHeader)) {
      headers.remove(ServerRequestResponseConstants.acceptHeader);
    }

    options.headers.addAll(headers);

    handler.next(options);
  }

  Future<Map<String, dynamic>> getHeaders() async {
    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      ServerRequestResponseConstants.acceptHeader: '*/*',
      'apiKey': UrlConstants.apiKey,
    };

    // Read the token from secure storage
    final token = await _secureStorage.read(key: SharedPreferenceKeys.token);
    if (token != null && token.isNotEmpty) {
      final tokenHeader = {'Authorization': 'Bearer $token'};
      headers.addAll(tokenHeader);
    }

    return headers;
  }
}
