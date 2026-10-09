import 'package:flutter/material.dart';

// ── Noir Glass + Pearl Teal palettes ─────────────────────────────────────────
class AppColorPalette {
  AppColorPalette._();

  static bool isLight = false;

  static void setLight(bool value) => isLight = value;
}

Color get primaryColor =>
    AppColorPalette.isLight ? const Color(0xFF0B7266) : const Color(0xFF2DD4BF);
Color get primaryShadeColor =>
    AppColorPalette.isLight ? const Color(0xFFE2F3EF) : const Color(0xFF0D3D38);
Color get primaryShade1Color =>
    AppColorPalette.isLight ? const Color(0xFFE8F3EF) : const Color(0xFF0A2825);
Color get onPrimaryColor =>
    AppColorPalette.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF042F2E);

Color get secondaryColor =>
    AppColorPalette.isLight ? const Color(0xFF0B7266) : const Color(0xFF5EEAD4);
Color get secondaryShadeColor =>
    AppColorPalette.isLight ? const Color(0xFFE2F3EF) : const Color(0xFF134E4A);
Color get secondaryShade1Color =>
    AppColorPalette.isLight ? const Color(0xFF0B7266) : const Color(0xFF0F766E);

Color get greenColor => AppColorPalette.isLight ? const Color(0xFF08755C) : const Color(0xFF34D399);
Color get checkColor => AppColorPalette.isLight ? const Color(0xFF08755C) : const Color(0xFF34D399);
Color get redColor => AppColorPalette.isLight ? const Color(0xFFB84856) : const Color(0xFFFB7185);

Color get disableColor =>
    AppColorPalette.isLight ? const Color(0xFF869994) : const Color(0xFF52525B);
const whiteColor = Color(0xFFFFFFFF);
Color get surfaceColor =>
    AppColorPalette.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF121214);
Color get blackColor => AppColorPalette.isLight ? const Color(0xFF172B28) : const Color(0xFFEDEDEF);
Color get backgroundIconColor =>
    AppColorPalette.isLight ? const Color(0xFFE8F3EF) : const Color(0xFF1A1A1D);
const transParentColor = Colors.transparent;

Color get scaffoldBackgroundColor =>
    AppColorPalette.isLight ? const Color(0xFFF4F7F5) : const Color(0xFF050506);

Color get backgroundSecondaryBeige => scaffoldBackgroundColor;
Color get backgroundSecondaryBeigeLight =>
    AppColorPalette.isLight ? const Color(0xFFEEF3F0) : const Color(0xFF0A0A0C);
Color get backgroundPrimaryBeige => surfaceColor;
Color get backgroundSecondaryBlueGrey => scaffoldBackgroundColor;
Color get backgroundPrimaryBlueGrey => surfaceColor;
Color get backgroundGrey => backgroundIconColor;
Color get frameColor => AppColorPalette.isLight ? const Color(0xFFDBE6E1) : const Color(0xFF2A2A2E);
Color get backgroundDisabled =>
    AppColorPalette.isLight ? const Color(0xFFC7D3CE) : const Color(0xFF71717A);
Color get backgroundHover =>
    AppColorPalette.isLight ? const Color(0xFF526964) : const Color(0xFFA1A1AA);
Color get backgroundAlert =>
    AppColorPalette.isLight ? const Color(0xFFFFE9EB) : const Color(0xFF3F1D24);
Color get backgroundShimmer => backgroundIconColor;
Color get backgroundShimmerHighlight =>
    AppColorPalette.isLight ? const Color(0x40DBE6E1) : const Color(0x402A2A2E);
const green1 = Color(0xFF059669);
Color get progressBarColor => primaryColor;
Color get progressBarBackgroundColor => backgroundIconColor;

Color get accentGreen => primaryColor;
Color get alertColor => redColor;
const iconYellow = Color(0xFFFBBF24);
Color get navyColor => blackColor;
Color get statusLightGreen => primaryShadeColor;
Color get statusLightOrange =>
    AppColorPalette.isLight ? const Color(0xFFFFF0D6) : const Color(0xFF3F2A12);
Color get mediumLightGray =>
    AppColorPalette.isLight ? const Color(0xFF526964) : const Color(0xFF71717A);
const skyBlue = Color(0xFF22D3EE);
Color get activeRed => redColor.withValues(alpha: 0.2);
const backgroundOverlayColor = Color(0x99000000);

Color get greyColor => AppColorPalette.isLight ? const Color(0xFFDBE6E1) : const Color(0xFF3F3F46);
Color get darkGreyColor =>
    AppColorPalette.isLight ? const Color(0xFF526964) : const Color(0xFF8A8F98);

Color get weakPasswordColor => redColor;
const slightlyWeakPasswordColor = Color(0xFFFBBF24);
const normalPasswordColor = Color(0xFFFDE047);
const strongPasswordColor = Color(0xFFA3E635);
Color get veryStrongPasswordColor => greenColor;

Color get fieldFillColor =>
    AppColorPalette.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1D);
Color get fieldErrorColor => redColor;

/// 8% white hairline — glass panel edges (MASTER).
Color get glassHairlineColor =>
    AppColorPalette.isLight ? const Color(0xFFDBE6E1) : const Color(0x14FFFFFF);

/// Slightly lifted top of a glass panel.
Color get surfaceHighlightColor =>
    AppColorPalette.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1E);

List<BoxShadow> get softCardShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.32),
    blurRadius: 20,
    offset: const Offset(0, 10),
  ),
];

List<BoxShadow> get ctaGlowShadow => [
  BoxShadow(
    color: primaryColor.withValues(alpha: 0.28),
    blurRadius: 18,
    offset: const Offset(0, 8),
  ),
];
