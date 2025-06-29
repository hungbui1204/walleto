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
    final isRevokeRefeshToken =
        options.extra[ServerRequestResponseConstants.revokeRefreshToken] == true;

    final headers = await getHeaders(isRevokeRefeshToken);

    options.headers.addAll(headers);

    handler.next(options);
  }

  Future<Map<String, dynamic>> getHeaders(bool isRevokeRefeshToken) async {
    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'apiKey': UrlConstants.apiKey,
    };

    // Read the token from secure storage
    final token = await _secureStorage.read(key: SharedPreferenceKeys.token);
    if (token != null && token.isNotEmpty) {
      final tokenHeader = {'Authorization': 'Bearer $token'};
      headers.addAll(tokenHeader);
    }

    // If the request is for revoking the refresh token, add the refresh token to headers
    if (isRevokeRefeshToken) {
      final refreshToken = await _secureStorage.read(key: SharedPreferenceKeys.refreshToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshTokenHeader = {'Authorization': 'Bearer $refreshToken'};
        headers.addAll(refreshTokenHeader);
      }
    }

    return headers;
  }
}
