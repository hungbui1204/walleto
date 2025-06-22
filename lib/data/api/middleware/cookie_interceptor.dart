import 'package:cookie_jar/cookie_jar.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class CookieInterceptor extends BaseInterceptor {
  CookieInterceptor(this._cookieHelper, this._secureStorage);

  final CookieHelper _cookieHelper;
  final FlutterSecureStorage _secureStorage;

  @override
  int get priority => BaseInterceptor.cookiePriority;

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cookies = await _cookieHelper.cookieManager.cookieJar.loadForRequest(options.uri);

    final String? fcmToken = options.extra[ServerRequestResponseConstants.fcmToken];
    if (fcmToken != null) {
      cookies.add(
        Cookie(
          ServerRequestResponseConstants.dToken,
          options.extra[ServerRequestResponseConstants.fcmToken],
        ),
      );
    }

    if (cookies.isNotEmpty) {
      options.headers[ServerRequestResponseConstants.cookieKey] = cookies.join(';');
    }

    handler.next(options);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cookies = response.headers[ServerRequestResponseConstants.setCookieKey];

    if (cookies != null) {
      await _cookieHelper.cookieManager.cookieJar.saveFromResponse(
        response.realUri,
        await _getCookies(cookies),
      );
    }

    handler.next(response);
  }

  Future<List<Cookie>> _getCookies(List<String> cookies) async {
    final cookieList = <Cookie>[];

    for (final cookie in cookies) {
      cookieList.add(Cookie.fromSetCookieValue(cookie));
    }

    final token = cookieList.firstOrNullWhere(
      (cookie) => cookie.name == SharedPreferenceKeys.token,
    );
    if (token != null) {
      await _secureStorage.write(key: SharedPreferenceKeys.token, value: token.value);
    }

    return cookieList;
  }
}
