import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walleto/shared/shared.dart';

@singleton
class AppPreferences {
  AppPreferences(this._sharedPreference, this._secureStorage);

  final SharedPreferencesAsync _sharedPreference;
  final FlutterSecureStorage _secureStorage;

  Future<bool> get isLoggedIn async {
    final token = await _secureStorage.read(key: SharedPreferenceKeys.token);

    return token != null;
  }
}