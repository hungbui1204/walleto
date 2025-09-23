import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/firebase_options.dart';
import 'package:walleto/ui/ui.dart';

import 'config/app_config.dart';
import 'di/di.dart';
import 'initializer/application_initializer.dart';
import 'shared/shared.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() => runZonedGuarded(_runMyApp, _reportError);

Future<void> _runMyApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer(AppConfig.getInstance()).init();

  if (Platform.isAndroid) {
    // TODO: implement push noti for iOS
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final initialResource = await _loadInitialResource();

  runApp(WalletoApplication(initialResource: initialResource));
}

Future<void> _reportError(Object error, StackTrace stackTrace) async {
  Log.e(error, stackTrace: stackTrace, name: 'Uncaught exception');
}

Future<LoadInitialResourceOutput> _loadInitialResource() async {
  final result = runCatching(
    action: () async {
      final prefs = getIt.get<SharedPreferencesAsync>();

      /// English:
      /// Remove all data when the app is launched for the first time.
      /// On Android, secure storage data is not cleared when the app is uninstalled.
      if (await prefs.getBool(SharedPreferenceKeys.isFirstLaunchApp) ?? true) {
        await getIt.get<FlutterSecureStorage>().deleteAll();
        prefs.setBool(SharedPreferenceKeys.isFirstLaunchApp, false);
      }

      return getIt.get<LoadInitialResourceUseCase>().execute(const LoadInitialResourceInput());
    },
  );

  return switch (result) {
    Success(:final data) => data,
    Failure() => const LoadInitialResourceOutput(),
  };
}
