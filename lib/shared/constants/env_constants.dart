import 'package:walleto/shared/shared.dart';

class EnvConstants {
  const EnvConstants._();

  static const flavorKey = 'FLAVOR';
  static const appApiDomainKey = 'APP_API_DOMAIN';
  static const appApiKeyKey = 'APP_API_KEY';

  static Flavor flavor = Flavor.values.byName(
    const String.fromEnvironment(flavorKey, defaultValue: 'develop'),
  );
  static String appApiDomain = const String.fromEnvironment(appApiDomainKey);
  static String appApiKey = const String.fromEnvironment(appApiKeyKey);

  static void init() {
    Log.d(flavor, name: flavorKey);
    Log.d(appApiDomain, name: appApiDomainKey);
    Log.d(appApiKey, name: appApiKeyKey);
  }
}
