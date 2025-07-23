import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

@lazySingleton
class RefreshTokenManager {
  RefreshTokenManager(this._repository);

  final Repository _repository;
  Completer<void>? _refreshCompleter;

  Future<void> refreshToken() async {
    if (_refreshCompleter != null) {
      await _refreshCompleter!.future;
      return;
    }

    _refreshCompleter = Completer<void>();
    try {
      final refreshToken = await _repository.refreshToken;
      await _repository.refreshAuthToken(refreshToken: refreshToken);
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
    } finally {
      _refreshCompleter = null;
    }
  }
}
