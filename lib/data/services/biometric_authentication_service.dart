import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class BiometricAuthenticationService {
  const BiometricAuthenticationService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> get isAvailable async {
    try {
      if (!await _localAuthentication.canCheckBiometrics) return false;
      final availableBiometrics = await _localAuthentication.getAvailableBiometrics();
      if (Platform.isAndroid) {
        return availableBiometrics.contains(BiometricType.strong);
      }
      if (Platform.isIOS) {
        return availableBiometrics.contains(BiometricType.face) ||
            availableBiometrics.contains(BiometricType.fingerprint);
      }
      return false;
    } on Object catch (error, stackTrace) {
      Log.e(error, stackTrace: stackTrace, name: 'Failed to inspect biometric availability');
      return false;
    }
  }
}
