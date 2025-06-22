import 'package:walleto/shared/shared.dart';


class LocaleUtils {
  const LocaleUtils._();

  static String getCountryCodeByLocale(String locale) {
    final map = {
      LocaleConstants.en: CountryCodeConstant.us,
    };

    return map[locale] ?? '';
  }
}
