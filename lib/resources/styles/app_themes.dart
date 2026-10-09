import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';

class AppThemes {
  const AppThemes._();

  static const String displayFont = FontFamily.spaceGrotesk;
  static const String bodyFont = FontFamily.dMSans;

  static ThemeData get appTheme => darkTheme;

  static ThemeData get lightTheme => _buildTheme(light: true);

  static ThemeData get darkTheme => _buildTheme(light: false);

  static ThemeData _buildTheme({required bool light}) {
    AppColorPalette.setLight(light);
    final brightness = light ? Brightness.light : Brightness.dark;
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final baseTextTheme = base.textTheme.apply(
      fontFamily: bodyFont,
      bodyColor: blackColor,
      displayColor: blackColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: bodyFont,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: light
          ? ColorScheme.light(
              primary: primaryColor,
              onPrimary: onPrimaryColor,
              secondary: secondaryColor,
              onSecondary: onPrimaryColor,
              surface: surfaceColor,
              onSurface: blackColor,
              error: redColor,
              onError: onPrimaryColor,
            )
          : ColorScheme.dark(
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
      iconTheme: IconThemeData(color: blackColor),
      appBarTheme: AppBarTheme(
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(color: frameColor, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          // Matches panel radius token (d16). ThemeData is built once at app start.
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimens.d16)),
          side: BorderSide(color: glassHairlineColor),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Dimens.d16)),
          side: BorderSide(color: glassHairlineColor),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionHandleColor: primaryColor,
        selectionColor: primaryColor.withValues(alpha: 0.28),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
            backgroundColor: scaffoldBackgroundColor,
          ),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        },
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        unselectedLabelColor: darkGreyColor,
        dividerColor: frameColor,
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: WidgetStatePropertyAll(primaryShade1Color),
        labelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
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
          side: WidgetStatePropertyAll(BorderSide(color: frameColor)),
        ),
      ),
      datePickerTheme: datePicker,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static DatePickerThemeData get datePicker {
    final shape = RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(Radius.circular(Dimens.d16)),
      side: BorderSide(color: glassHairlineColor),
    );

    return DatePickerThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: shape,
      headerBackgroundColor: primaryShadeColor,
      headerForegroundColor: blackColor,
      headerHeadlineStyle: display(),
      dividerColor: glassHairlineColor,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return onPrimaryColor;
        if (states.contains(WidgetState.disabled)) return darkGreyColor;
        return blackColor;
      }),
      dayBackgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        return transParentColor;
      }),
      dayShape: WidgetStateOutlinedBorder.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return LinearBorder(side: BorderSide(color: primaryColor));
        }

        return const LinearBorder(side: BorderSide(color: transParentColor));
      }),
      todayForegroundColor: WidgetStatePropertyAll(primaryColor),
      todayBorder: BorderSide(color: primaryColor),
      rangePickerElevation: 0,
      rangePickerBackgroundColor: surfaceColor,
      rangePickerHeaderBackgroundColor: primaryShadeColor,
      rangePickerHeaderForegroundColor: blackColor,
      rangePickerHeaderHeadlineStyle: display(),
      rangeSelectionBackgroundColor: primaryShade1Color,
    );
  }

  static TextStyle amount({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double height = 1.15,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? blackColor,
      height: height,
      letterSpacing: -0.5,
    );
  }

  static TextStyle display({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double height = 1.15,
    double letterSpacing = -0.4,
  }) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? blackColor,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
