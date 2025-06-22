class RegexConstants {
  const RegexConstants._();

  static final password = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*$');

  static final specialCharacter = RegExp(r'[!@#$%^&*()_+\-=[\]{};:"\\|,.<>/?~]');

  static final phoneNumber = RegExp(r'^(?:0\d{1,4}-\d{1,4}-\d{4}|0\d{9,10})$');

  static final email = RegExp(
    r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static final dateTime = RegExp(
    r'^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$',
  );

  static final space = RegExp(r'\s');

  static final alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');

  static final number = RegExp(r'[0-9]');

  static final numberTwoBytes = RegExp(r'[０-９]');

  static final numberKanji = RegExp(r'/[無〇一二三四五六七八九]/');

  static final addressInfoString = RegExp(r'/[丁番東西南北ー\-]/');

  static final dateText = RegExp(r'\d{4}年\d{1,2}月\d{1,2}日');

  static final zipCode = RegExp(r'(\d{3})(\d{4})');

  static final kana = RegExp(r'^[ァ-ンヴー]*$');

  static final link = RegExp(r'(?:(?:http?|ftp)://)?https://[\w/\-?=%.]+\.[\w/\-?=%.]+');

  static final passwordWithSpecialChars = RegExp(
    r'''^[A-Za-z0-9!"#$%&'()*+,\-./:;<=>?@\[\]\\^_`{|}~]+$''',
  );
}
