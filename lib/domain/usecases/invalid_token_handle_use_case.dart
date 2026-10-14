import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'invalid_token_handle_use_case.freezed.dart';

@injectable
class InvalidTokenHandleUseCase
    extends BaseFutureUseCase<InvalidTokenHandleInput, InvalidTokenHandleOutput> {
  const InvalidTokenHandleUseCase(this._repository, this._refreshTokenManager);

  final Repository _repository;
  final RefreshTokenManager _refreshTokenManager;

  @protected
  @override
  Future<InvalidTokenHandleOutput> buildUseCase(InvalidTokenHandleInput input) async {
    final isLoggedIn = await _repository.isLoggedIn;

    // 1. The token is empty in secure storage (user is not logged in or clear data)
    //    -> return [InvalidTokenHandlerStatus.emptyToken]
    if (!isLoggedIn) {
      return const InvalidTokenHandleOutput();
    }

    // 2. The token in secure storage is expired
    //      -> try to refresh the token by refresh token manager
    //      -> return [InvalidTokenHandlerStatus.tokenRefreshed] if the refresh token is successful
    //      -> return [InvalidTokenHandlerStatus.refreshTokenExpired] if the refresh token is expired
    try {
      await _refreshTokenManager.refreshToken();

      return const InvalidTokenHandleOutput(status: InvalidTokenHandlerStatus.tokenRefreshed);
    } on RemoteException catch (e) {
      if (_isRejectedRefreshToken(e)) {
        // 3. The refresh token is expired
        //    -> return [InvalidTokenHandlerStatus.refreshTokenExpired]
        return const InvalidTokenHandleOutput(
          status: InvalidTokenHandlerStatus.refreshTokenExpired,
        );
      }

      return const InvalidTokenHandleOutput(status: InvalidTokenHandlerStatus.refreshFailed);
    } catch (_) {
      return const InvalidTokenHandleOutput(status: InvalidTokenHandlerStatus.refreshFailed);
    }
  }

  bool _isRejectedRefreshToken(RemoteException error) {
    return AuthSessionConstants.isRejectedRefreshToken(
      httpStatusCode: error.httpErrorCode,
      errorCode: error.generalServerErrorId,
    );
  }
}

@freezed
sealed class InvalidTokenHandleInput extends BaseInput with _$InvalidTokenHandleInput {
  const InvalidTokenHandleInput._();

  const factory InvalidTokenHandleInput() = _InvalidTokenHandleInput;
}

@freezed
sealed class InvalidTokenHandleOutput extends BaseOutput with _$InvalidTokenHandleOutput {
  const InvalidTokenHandleOutput._();

  const factory InvalidTokenHandleOutput({
    @Default(InvalidTokenHandlerStatus.emptyToken) InvalidTokenHandlerStatus status,
  }) = _InvalidTokenHandleOutput;
}
