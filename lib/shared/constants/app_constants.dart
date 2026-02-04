import 'dart:ui';

import 'package:walleto/resources/resources.dart';

class AppConstants {
  const AppConstants._();

  static const int maxTransactionAmountLength = 15;
  static const int firstYear = 2020;
  static const int lastYear = 2030;

  static const List<Color> pieChartColors = [
    primaryColor,
    secondaryColor,
    greenColor,
    redColor,
    navyColor,
    accentGreen,
    disableColor,
  ];

  static const totalWalletId = -1;

  static const defaultCurrencyCode = 'USD';

  // This category id is used for updating wallet balance
  static const updateWalletBalanceCategoryId = 999;
}
