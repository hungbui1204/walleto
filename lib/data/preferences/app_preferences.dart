import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@singleton
class AppPreferences {
  AppPreferences(this._secureStorage, @Named('biometric') this._biometricStorage)
    : _sharedPreferences = SharedPreferencesAsync();

  final FlutterSecureStorage _secureStorage;
  final FlutterSecureStorage _biometricStorage;
  final SharedPreferencesAsync _sharedPreferences;
  static const _uuid = Uuid();
  static const _biometricRefreshTokenKey = 'biometricRefreshToken';
  static const _biometricProbeKey = 'biometricProbe';
  static const _installationMarkerName = 'walleto_installation_marker';

  Future<String?> get appThemePreference async {
    return _sharedPreferences.getString(SharedPreferenceKeys.appThemePreference);
  }

  Future<void> setAppThemePreference(String value) async {
    await _sharedPreferences.setString(SharedPreferenceKeys.appThemePreference, value);
  }

  Future<String?> get token async {
    return await _secureStorage.read(key: SharedPreferenceKeys.token);
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: SharedPreferenceKeys.token, value: token);
  }

  Future<DateTime?> get sessionExpiresAt async {
    final value = await _secureStorage.read(key: SharedPreferenceKeys.sessionExpiresAt);
    final epochSeconds = int.tryParse(value ?? '');
    return epochSeconds == null ? null : DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
  }

  Future<String?> get refreshToken async {
    final refreshToken = await _secureStorage.read(key: SharedPreferenceKeys.refreshToken);

    return refreshToken;
  }

  Future<void> setRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: SharedPreferenceKeys.refreshToken, value: refreshToken);
  }

  Future<void> saveSession(Authentication authentication) async {
    final expiresAt =
        authentication.expiresAt ??
        (authentication.expiresIn > 0
            ? DateTime.now().add(Duration(seconds: authentication.expiresIn))
            : null);
    if (authentication.accessToken.isEmpty ||
        authentication.refreshToken.isEmpty ||
        authentication.user.id.isEmpty ||
        expiresAt == null ||
        !expiresAt.isAfter(DateTime.now())) {
      throw const AppUncaughtException('Supabase returned an incomplete or expired session');
    }

    await _sharedPreferences.setBool(SharedPreferenceKeys.sessionWritePending, true);
    try {
      // Write the rotating refresh credential first; clear the whole session if any write fails.
      await _secureStorage.write(
        key: SharedPreferenceKeys.refreshToken,
        value: authentication.refreshToken,
      );
      await _secureStorage.write(
        key: SharedPreferenceKeys.token,
        value: authentication.accessToken,
      );
      await _secureStorage.write(key: SharedPreferenceKeys.userId, value: authentication.user.id);
      await _secureStorage.write(
        key: SharedPreferenceKeys.userEmail,
        value: authentication.user.email,
      );
      await _secureStorage.write(
        key: SharedPreferenceKeys.sessionExpiresAt,
        value: '${expiresAt.millisecondsSinceEpoch ~/ 1000}',
      );
      await _sharedPreferences.setBool(SharedPreferenceKeys.sessionWritePending, false);
    } on Object {
      await clearSession();
      await _sharedPreferences.setBool(SharedPreferenceKeys.sessionWritePending, false);
      rethrow;
    }
  }

  Future<void> clearCurrentUserData() async {
    await clearSession();
  }

  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: SharedPreferenceKeys.token),
      _secureStorage.delete(key: SharedPreferenceKeys.refreshToken),
      _secureStorage.delete(key: SharedPreferenceKeys.userId),
      _secureStorage.delete(key: SharedPreferenceKeys.userEmail),
      _secureStorage.delete(key: SharedPreferenceKeys.sessionExpiresAt),
    ]);
  }

  Future<void> setUserId(String userId) async {
    await _secureStorage.write(key: SharedPreferenceKeys.userId, value: userId);
  }

  Future<String?> get userId async {
    return await _secureStorage.read(key: SharedPreferenceKeys.userId);
  }

  Future<String?> get userEmail async =>
      await _secureStorage.read(key: SharedPreferenceKeys.userEmail);

  Future<bool> get isBiometricLoginEnabled async =>
      await _sharedPreferences.getBool(SharedPreferenceKeys.biometricLoginEnabled) ?? false;

  Future<String?> get biometricLoginUserId async =>
      await _secureStorage.read(key: SharedPreferenceKeys.biometricLoginUserId);

  Future<bool> get biometricCredentialPresent async =>
      await _sharedPreferences.getBool(SharedPreferenceKeys.biometricCredentialPresent) ?? false;

  Future<bool> get biometricTransferPending async =>
      await _sharedPreferences.getBool(SharedPreferenceKeys.biometricTransferPending) ?? false;

  Future<void> setBiometricTransferPending(bool value) =>
      _sharedPreferences.setBool(SharedPreferenceKeys.biometricTransferPending, value);

  Future<void> setBiometricLogin({required bool enabled, required String userId}) async {
    if (enabled) {
      await _secureStorage.write(key: SharedPreferenceKeys.biometricLoginUserId, value: userId);
      await _sharedPreferences.setBool(SharedPreferenceKeys.biometricLoginEnabled, true);
      return;
    }

    await clearBiometricLogin();
  }

  Future<String?> readBiometricRefreshToken() =>
      _biometricStorage.read(key: _biometricRefreshTokenKey);

  Future<void> writeBiometricRefreshToken(String refreshToken) =>
      _biometricStorage.write(key: _biometricRefreshTokenKey, value: refreshToken);

  Future<void> writeBiometricProbe(String secret) =>
      _biometricStorage.write(key: _biometricProbeKey, value: secret);

  Future<String?> readBiometricProbe() => _biometricStorage.read(key: _biometricProbeKey);

  Future<void> clearBiometricProbe() => _biometricStorage.delete(key: _biometricProbeKey);

  Future<void> clearBiometricCredential() async {
    await _biometricStorage.delete(key: _biometricRefreshTokenKey);
    await _sharedPreferences.setBool(SharedPreferenceKeys.biometricCredentialPresent, false);
  }

  Future<void> markBiometricCredentialPresent() =>
      _sharedPreferences.setBool(SharedPreferenceKeys.biometricCredentialPresent, true);

  Future<void> clearBiometricLogin() async {
    await _sharedPreferences.setBool(SharedPreferenceKeys.biometricLoginEnabled, false);
    await _sharedPreferences.setBool(SharedPreferenceKeys.biometricCredentialPresent, false);
    await _secureStorage.delete(key: SharedPreferenceKeys.biometricLoginUserId);
    try {
      await _biometricStorage.deleteAll();
    } on Object catch (error, stackTrace) {
      Log.e(error, stackTrace: stackTrace, name: 'Failed to clear protected biometric data');
    }
  }

  Future<String> getInstallationId() async {
    final existingId = await _secureStorage.read(key: SharedPreferenceKeys.installationId);
    if (existingId != null && existingId.isNotEmpty) return existingId;

    final newId = _uuid.v4();
    await _secureStorage.write(key: SharedPreferenceKeys.installationId, value: newId);
    return newId;
  }

  /// Runs before any session read. Cache lives outside backup/restore; loss fails closed.
  Future<void> initializeInstallation() async {
    final cacheDirectory = await getTemporaryDirectory();
    final marker = File('${cacheDirectory.path}${Platform.pathSeparator}$_installationMarkerName');
    if (!await marker.exists()) {
      await clearSession();
      await clearBiometricLogin();
      await _secureStorage.delete(key: SharedPreferenceKeys.installationId);
      await getInstallationId();
      await marker.writeAsString('initialized', flush: true);
    }

    if (await _sharedPreferences.getBool(SharedPreferenceKeys.sessionWritePending) ?? false) {
      await clearSession();
      await _sharedPreferences.setBool(SharedPreferenceKeys.sessionWritePending, false);
    }

    if (await _sharedPreferences.getBool(SharedPreferenceKeys.biometricTransferPending) ?? false) {
      await clearSession();
      await clearBiometricLogin();
      await _sharedPreferences.setBool(SharedPreferenceKeys.biometricTransferPending, false);
    }
  }
}
