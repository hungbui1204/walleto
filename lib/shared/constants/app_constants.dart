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
}
