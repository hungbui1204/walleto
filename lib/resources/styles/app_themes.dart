import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AppThemes {
  const AppThemes._();

  static final appTheme = ThemeData(
    primaryColor: backgroundPrimaryBlueGrey,
    brightness: Brightness.light,
    // fontFamily: FontFamily.bIZUDPGothic,
    scaffoldBackgroundColor: whiteColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    iconTheme: const IconThemeData(color: blackColor),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: blackColor,
      selectionHandleColor: blackColor,
      selectionColor: blackColor.withValues(alpha: 0.3),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(backgroundColor: whiteColor),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
