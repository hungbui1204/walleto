import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleto/resources/resources.dart';

import 'di.config.dart';

@module
abstract class ServiceModule {
  @singleton
  SharedPreferencesAsync get prefs => SharedPreferencesAsync();

  @singleton
  FlutterSecureStorage get flutterSecureStorage {
    return const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }

  @singleton
  @Named('biometric')
  FlutterSecureStorage get biometricSecureStorage => FlutterSecureStorage(
    aOptions: AndroidOptions.biometric(
      enforceBiometrics: true,
      requireBiometricsPerOperation: true,
      biometricType: AndroidBiometricType.strongBiometricOnly,
      biometricPromptTitle: S.current.biometricAuthenticationTitle,
      biometricPromptSubtitle: S.current.biometricAuthenticationSubtitle,
      biometricPromptNegativeButton: S.current.cancel,
    ),
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
      accessControlFlags: [AccessControlFlag.biometryCurrentSet],
      useSecureEnclave: true,
    ),
  );

  @singleton
  LocalAuthentication get localAuthentication => LocalAuthentication();
}

final getIt = GetIt.instance;

@injectableInit
void configureDependencies() => getIt.init();
