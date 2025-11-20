import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeToEdgeHelper {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized || !Platform.isAndroid) return;

    // Set the system UI mode to edge-to-edge
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Customize the system UI overlay styles for edge-to-edge experience
    // Default values can be adjusted based on the app's theme

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    _isInitialized = true;
  }

  /// Get navigation bar height
  static double getNavigationBarHeight(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return padding.bottom;
  }
}
