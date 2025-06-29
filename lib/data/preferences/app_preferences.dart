import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/shared/shared.dart';

@singleton
class AppPreferences {
  AppPreferences(this._secureStorage);

  // final SharedPreferencesAsync _sharedPreference;
  final FlutterSecureStorage _secureStorage;

  Future<String?> get token async {
    return await _secureStorage.read(key: SharedPreferenceKeys.token);
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: SharedPreferenceKeys.token, value: token);
  }

  Future<String?> get refreshToken async {
    final refreshToken = await _secureStorage.read(key: SharedPreferenceKeys.refreshToken);

    return refreshToken;
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: SharedPreferenceKeys.refreshToken, value: refreshToken);
  }

  Future<void> clearCurrentUserData() async {
    await Future.wait([
      _secureStorage.delete(key: SharedPreferenceKeys.token),
      _secureStorage.delete(key: SharedPreferenceKeys.refreshToken),
    ]);
  }
}
