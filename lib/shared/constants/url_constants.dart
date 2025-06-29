import 'package:walleto/shared/shared.dart';

class UrlConstants {
  const UrlConstants._();

  static const listApiUriWithoutAuth = ['/sign-in', '/display/notices', '/mfa-sign-in'];

  static String get twitter => 'https://twitter.com/';
  static String get instagram => 'https://www.instagram.com/';
  static String get facebook => 'https://www.facebook.com/';

  static String get appApiBaseUrlAuth => '${EnvConstants.appApiDomain}/auth/v1/';
  static String get appApiBaseUrlRest => '${EnvConstants.appApiDomain}/rest/v1/';
  static String get apiKey => EnvConstants.appApiKey;
}
