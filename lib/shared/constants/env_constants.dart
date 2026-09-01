import 'package:walleto/shared/shared.dart';

class EnvConstants {
  const EnvConstants._();

  static const flavorKey = 'FLAVOR';
  static const appApiDomainKey = 'APP_API_DOMAIN';
  static const appApiKeyKey = 'APP_API_KEY';
  static const appApiFunctionsDomainKey = 'APP_API_FUNCTIONS_DOMAIN';

  static Flavor flavor = Flavor.values.byName(
    const String.fromEnvironment(flavorKey, defaultValue: 'develop'),
  );
  static String appApiDomain = const String.fromEnvironment(appApiDomainKey);
  static String appApiKey = const String.fromEnvironment(appApiKeyKey);
  static String appApiFunctionsDomain = const String.fromEnvironment(appApiFunctionsDomainKey);

  static void init() {
    Log.d(flavor, name: flavorKey);
    Log.d(appApiDomain, name: appApiDomainKey);
    final apiKeyStatus = appApiKey.isEmpty ? 'empty' : 'set';
    Log.d(apiKeyStatus, name: appApiKeyKey);
    Log.d(appApiFunctionsDomain, name: appApiFunctionsDomainKey);
  }
}
