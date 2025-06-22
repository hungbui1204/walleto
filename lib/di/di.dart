import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di.config.dart';


@module
abstract class ServiceModule{
  @singleton
  SharedPreferencesAsync get prefs => SharedPreferencesAsync();

  @singleton
  FlutterSecureStorage get flutterSecureStorage {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
  }
}

final getIt = GetIt.instance;

@injectableInit
void configureDependencies() => getIt.init();