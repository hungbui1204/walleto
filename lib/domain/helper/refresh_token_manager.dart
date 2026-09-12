import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

@lazySingleton
class RefreshTokenManager {
  RefreshTokenManager(this._repository);

  final Repository _repository;
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
        final refreshToken = await _repository.refreshToken;
        await _repository.refreshAuthToken(refreshToken: refreshToken);
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
}
