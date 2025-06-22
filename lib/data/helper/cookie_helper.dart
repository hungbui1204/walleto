import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/shared/shared.dart';

@LazySingleton()
class CookieHelper {
  CookieManager? _cookieManager;

  CookieManager get cookieManager => _cookieManager!;

  Future<void> init() async {
    final jar = PersistCookieJar(storage: FileStorage(await FileUtils.getCookiePath()));
    _cookieManager = CookieManager(jar);
  }
}
