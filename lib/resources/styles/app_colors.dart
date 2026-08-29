import 'package:flutter/material.dart';

// ── Noir Glass — dark OLED + teal accent ─────────────────────────────────────
const primaryColor = Color(0xFF2DD4BF);
const primaryShadeColor = Color(0xFF0D3D38);
const primaryShade1Color = Color(0xFF0A2825);
const onPrimaryColor = Color(0xFF042F2E);

const secondaryColor = Color(0xFF5EEAD4);
const secondaryShadeColor = Color(0xFF134E4A);
const secondaryShade1Color = Color(0xFF0F766E);

const greenColor = Color(0xFF34D399);
const checkColor = Color(0xFF34D399);
const redColor = Color(0xFFFB7185);

const disableColor = Color(0xFF52525B);
const whiteColor = Color(0xFFFFFFFF);
const surfaceColor = Color(0xFF121214);
const blackColor = Color(0xFFEDEDEF);
const backgroundIconColor = Color(0xFF1A1A1D);
const transParentColor = Colors.transparent;

const scaffoldBackgroundColor = Color(0xFF050506);

const backgroundSecondaryBeige = Color(0xFF050506);
const backgroundSecondaryBeigeLight = Color(0xFF0A0A0C);
const backgroundPrimaryBeige = Color(0xFF121214);
const backgroundSecondaryBlueGrey = Color(0xFF050506);
const backgroundPrimaryBlueGrey = Color(0xFF121214);
const backgroundGrey = Color(0xFF1A1A1D);
const frameColor = Color(0xFF2A2A2E);
const backgroundDisabled = Color(0xFF71717A);
const backgroundHover = Color(0xFFA1A1AA);
const backgroundAlert = Color(0xFF3F1D24);
const backgroundShimmer = Color(0xFF1A1A1D);
const backgroundShimmerHighlight = Color(0x402A2A2E);
const green1 = Color(0xFF059669);
const progressBarColor = Color(0xFF2DD4BF);
const progressBarBackgroundColor = Color(0xFF1A1A1D);

const accentGreen = Color(0xFF2DD4BF);
const alertColor = Color(0xFFFB7185);
const iconYellow = Color(0xFFFBBF24);
const navyColor = Color(0xFFEDEDEF);
const statusLightGreen = Color(0xFF0D3D38);
const statusLightOrange = Color(0xFF3F2A12);
const mediumLightGray = Color(0xFF71717A);
const skyBlue = Color(0xFF22D3EE);
const activeRed = Color(0x33FB7185);
const backgroundOverlayColor = Color(0x99000000);

const greyColor = Color(0xFF3F3F46);
const darkGreyColor = Color(0xFF8A8F98);

const weakPasswordColor = Color(0xFFFB7185);
const slightlyWeakPasswordColor = Color(0xFFFBBF24);
const normalPasswordColor = Color(0xFFFDE047);
const strongPasswordColor = Color(0xFFA3E635);
const veryStrongPasswordColor = Color(0xFF34D399);

const fieldFillColor = Color(0xFF1A1A1D);
const fieldErrorColor = Color(0xFFFB7185);

/// 8% white hairline — glass panel edges (MASTER).
const glassHairlineColor = Color(0x14FFFFFF);

/// Slightly lifted top of a glass panel.
const surfaceHighlightColor = Color(0xFF1A1A1E);

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
