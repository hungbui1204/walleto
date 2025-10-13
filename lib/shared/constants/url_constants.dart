import 'package:walleto/shared/shared.dart';

class UrlConstants {
  const UrlConstants._();

  static String get appApiBaseUrlAuth => '${EnvConstants.appApiDomain}/auth/v1/';
  static String get appApiBaseUrlRest => '${EnvConstants.appApiDomain}/rest/v1/';
  static String get appApiBaseUrlStorage => '${EnvConstants.appApiDomain}/storage/v1/object/list/';
  static String get appApiBaseUrlFunctions => EnvConstants.appApiFunctionsDomain;
  static String get apiKey => EnvConstants.appApiKey;
  static String categoryImageUrl(String path) =>
      '${EnvConstants.appApiDomain}/storage/v1/object/public/category-images/$path';
}
