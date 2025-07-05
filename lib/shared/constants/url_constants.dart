import 'package:walleto/shared/shared.dart';

class UrlConstants {
  const UrlConstants._();

  static String get appApiBaseUrlAuth => '${EnvConstants.appApiDomain}/auth/v1/';
  static String get appApiBaseUrlRest => '${EnvConstants.appApiDomain}/rest/v1/';
  static String get apiKey => EnvConstants.appApiKey;
}
