import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AppThemes {
  const AppThemes._();

  static const String displayFont = FontFamily.spaceGrotesk;
  static const String bodyFont = FontFamily.dMSans;

  static ThemeData get appTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final baseTextTheme = base.textTheme.apply(
      fontFamily: bodyFont,
      bodyColor: blackColor,
      displayColor: blackColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: bodyFont,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: secondaryColor,
        onSecondary: onPrimaryColor,
        surface: surfaceColor,
        onSurface: blackColor,
        error: redColor,
        onError: onPrimaryColor,
      ),
      textTheme: baseTextTheme,
      iconTheme: const IconThemeData(color: blackColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: blackColor,
          height: 1.15,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: darkGreyColor),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: frameColor,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(color: frameColor),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: frameColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionHandleColor: primaryColor,
        selectionColor: primaryColor.withValues(alpha: 0.28),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
            backgroundColor: scaffoldBackgroundColor,
          ),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: darkGreyColor,
        dividerColor: frameColor,
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: WidgetStatePropertyAll(primaryShade1Color),
        labelStyle: TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryShadeColor;
            return surfaceColor;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return primaryColor;
            return darkGreyColor;
          }),
          side: const WidgetStatePropertyAll(BorderSide(color: frameColor)),
        ),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static TextStyle amount({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = blackColor,
    double height = 1.15,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle display({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    Color color = blackColor,
    double height = 1.15,
    double letterSpacing = -0.4,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
