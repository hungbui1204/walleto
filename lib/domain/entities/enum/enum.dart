import 'package:walleto/shared/constants/locale_constants.dart';

enum InitialAppRoute { login, main }

enum LanguageCode {
  en(value: 1, localeCode: LocaleConstants.en);

  const LanguageCode({required this.value, required this.localeCode});

  final int value;
  final String localeCode;

  static const defaultValue = en;
}

enum InvalidTokenHandlerStatus { emptyToken, tokenRefreshed, refreshTokenExpired }

enum ImagePlaceHolderType { category, wallet, user, currency }

enum OperationType { addition, subtraction, multiplication, division }

enum CategoryType { expense, income }

enum TargetMonth { current, previous }

enum IconType { category, wallet }
