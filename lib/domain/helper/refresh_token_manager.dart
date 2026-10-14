import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@lazySingleton
class RefreshTokenManager {
  RefreshTokenManager(this._repository, this._authSessionCoordinator);

  final Repository _repository;
  final AuthSessionCoordinator _authSessionCoordinator;
  Completer<void>? _refreshCompleter;

  Future<void> refreshToken() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final completer = Completer<void>();
    _refreshCompleter = completer;

    unawaited(() async {
      try {
        await _authSessionCoordinator.runExclusive(() async {
          final refreshToken = await _repository.refreshToken;
          if (refreshToken.isEmpty) {
            throw const AppUncaughtException('Refresh token is missing');
          }
          try {
            await _repository.refreshAuthToken(refreshToken: refreshToken);
          } on RemoteException catch (error) {
            if (_isRejectedRefreshToken(error)) {
              await _repository.clearInvalidSession();
            }
            rethrow;
          }
        });
        if (!completer.isCompleted) {
          completer.complete();
        }
      } catch (e, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(e, stackTrace);
        }
      } finally {
        if (identical(_refreshCompleter, completer)) {
          _refreshCompleter = null;
        }
      }
    }());

    return completer.future;
  }

  Future<bool> ensureFreshSession() async {
    if (!await _repository.isLoggedIn) return false;

    return _authSessionCoordinator.runExclusive(() async {
      if (!await _repository.isLoggedIn) return false;
      final expiresAt = await _repository.sessionExpiresAt;
      if (expiresAt == null ||
          !expiresAt.isAfter(DateTime.now().add(AuthSessionConstants.refreshSafetyWindow))) {
        final refreshToken = await _repository.refreshToken;
        if (refreshToken.isEmpty) {
          await _repository.clearInvalidSession();
          return false;
        }
        try {
          await _repository.refreshAuthToken(refreshToken: refreshToken);
        } on RemoteException catch (error) {
          if (_isRejectedRefreshToken(error)) {
            await _repository.clearInvalidSession();
            return false;
          }
          rethrow;
        }
      }

      return true;
    });
  }

  bool _isRejectedRefreshToken(RemoteException error) {
    return AuthSessionConstants.isRejectedRefreshToken(
      httpStatusCode: error.httpErrorCode,
      errorCode: error.generalServerErrorId,
    );
  }
}
