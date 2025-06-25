import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class ExceptionHandler {
  const ExceptionHandler({required this.navigator, required this.listener});

  final AppNavigator navigator;
  final ExceptionHandlerListener listener;

  Future<void> handleException(
    AppExceptionWrapper appExceptionWrapper,
    String commonExceptionMessage,
  ) async {
    final message = appExceptionWrapper.overrideMessage ?? commonExceptionMessage;

    switch (appExceptionWrapper.appException.appExceptionType) {
      case AppExceptionType.remote:
        final exception = appExceptionWrapper.appException as RemoteException;
        switch (exception.kind) {
          case RemoteExceptionKind.forbidden:
            break;
          case RemoteExceptionKind.invalidToken:
            // When the token is invalid, there is 3 cases we need to handle:
            // 1. The token is empty in secure storage (user is not logged in or clear data)
            //      -> show error dialog and navigate to login screen
            // 2. The token in secure storage is expired
            //      -> try to refresh the token by using refresh token usecase
            //      -> if the refresh token is successful, try to retry the request
            // 3. The refresh token is expired -> show error dialog and navigate to login page
            await _showErrorDialog(
              isRefreshTokenFailed: true,
              message: message,
              onPressed: Func0(() => navigator.pop(useRootNavigator: true)),
            );
            break;
          case RemoteExceptionKind.noInternet:
          case RemoteExceptionKind.timeout:
            await _showErrorDialogWithRetry(
              message: message,
              onRetryPressed: Func0(() async {
                await navigator.pop(useRootNavigator: true);
                await appExceptionWrapper.doOnRetry?.call();
              }),
            );
            break;
          default:
            await _showErrorDialog(message: message);
            break;
        }
        break;
      case AppExceptionType.parse:
        return _showErrorSnackBar(message: message);
      case AppExceptionType.camera:
        await _showErrorDialog(message: message);
        return;
      case AppExceptionType.uncaught:
        return;
    }
  }

  void _showErrorSnackBar({
    required String message,
    Duration duration = DurationConstants.defaultErrorVisibleDuration,
  }) {
    navigator.showErrorSnackBar(message, duration: duration);
  }

  Future<void> _showErrorDialog({
    required String message,
    Func0<void>? onPressed,
    bool isRefreshTokenFailed = false,
  }) async {
    await navigator.showDialog(
      barrierDismissible: false,
      AppPopupInfo.confirm(message: message, onPressed: onPressed),
    );
    if (isRefreshTokenFailed) {
      listener.onInvalidToken();
    }
  }

  Future<void> _showErrorDialogWithRetry({
    required String message,
    required Func0<void>? onRetryPressed,
  }) async {
    await navigator.showDialog(
      AppPopupInfo.errorWithRetry(message: message, onRetryPressed: onRetryPressed),
    );
  }
}

abstract class ExceptionHandlerListener {
  void onInvalidToken();
}
