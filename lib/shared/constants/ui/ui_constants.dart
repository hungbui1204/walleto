import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UiConstants {
  const UiConstants._();

  /// material app
  static const appTitle = '自治体マイページ';

  /// orientation
  static const mobileOrientation = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  static const tabletOrientation = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// status bar color
  static const systemUiOverlay = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.transparent,
  );

  static final inputFormatterOtp = [
    LengthLimitingTextInputFormatter(6),
    FilteringTextInputFormatter.digitsOnly,
  ];

  static const myNumberLength = 12;
}
