import 'package:walleto/shared/shared.dart';

class UrlConstants {
  const UrlConstants._();

  static const listApiUriWithoutAuth = ['/sign-in', '/display/notices', '/mfa-sign-in'];

  static String get twitter => 'https://twitter.com/';
  static String get instagram => 'https://www.instagram.com/';
  static String get facebook => 'https://www.facebook.com/';


  static String get appApiBaseUrl => '${EnvConstants.appApiDomain}/api/client/v1';

  static String get appApiV2BaseUrl => '${EnvConstants.appApiDomain}/api/client/v2';

}
