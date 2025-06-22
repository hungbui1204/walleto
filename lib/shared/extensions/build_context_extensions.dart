import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  Size get sizeOf => MediaQuery.sizeOf(this);
  EdgeInsets get paddingOf => MediaQuery.paddingOf(this);
  ThemeData get theme => Theme.of(this);
  ScaffoldMessengerState get snackbar => ScaffoldMessenger.of(this);
  FocusScopeNode get focusScope => FocusScope.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get devicePixelRatioOf => MediaQuery.devicePixelRatioOf(this);
  TextScaler get textScalerOf => MediaQuery.textScalerOf(this);
}
