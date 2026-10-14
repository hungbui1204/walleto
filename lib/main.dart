import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:walleto/data/data.dart';
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

  await EdgeToEdgeHelper.initialize();

  await AppInitializer(AppConfig.getInstance()).init();

  if (Platform.isAndroid) {
    // TODO: implement push noti for iOS
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  final initialResource = await _loadInitialResource();
  final initialThemePreference = await _loadInitialThemePreference();

  runApp(
    WalletoApplication(
      initialResource: initialResource,
      initialThemePreference: initialThemePreference,
    ),
  );
}

Future<AppThemePreference> _loadInitialThemePreference() async {
  try {
    final output = await getIt.get<GetAppThemePreferenceUseCase>().execute(
      const GetAppThemePreferenceInput(),
    );

    return output.preference;
  } on Object catch (error, stackTrace) {
    Log.e(error, stackTrace: stackTrace, name: 'Failed to load app theme preference');

    return AppThemePreference.dark;
  }
}

Future<void> _reportError(Object error, StackTrace stackTrace) async {
  Log.e(error, stackTrace: stackTrace, name: 'Uncaught exception');
}

Future<LoadInitialResourceOutput> _loadInitialResource() async {
  final result = await runAsyncCatching(
    action: () async {
      await getIt.get<AppPreferences>().initializeInstallation();

      return getIt.get<LoadInitialResourceUseCase>().execute(const LoadInitialResourceInput());
    },
  );

  return switch (result) {
    Success(:final data) => data,
    Failure(:final exception) => _handleInitialSessionError(exception),
  };
}

LoadInitialResourceOutput _handleInitialSessionError(AppException exception) {
  Log.e(exception, name: 'Failed to validate the stored session during startup');
  return const LoadInitialResourceOutput(initialRoutes: [InitialAppRoute.login]);
}
