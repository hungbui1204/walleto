import 'package:walleto/shared/shared.dart';

class EnvConstants {
  const EnvConstants._();

  static const flavorKey = 'FLAVOR';
  static const appApiDomainKey = 'APP_API_DOMAIN';

  static Flavor flavor = Flavor.values.byName(
    const String.fromEnvironment(flavorKey, defaultValue: 'develop'),
  );
  static String appApiDomain = const String.fromEnvironment(appApiDomainKey);

  static void init() {
    Log.d(flavor, name: flavorKey);
    Log.d(appApiDomain, name: appApiDomainKey);
  }
}
