import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class ExceptionMessageMapper {
  const ExceptionMessageMapper();

  String map(AppException appException) {
    return switch (appException.appExceptionType) {
      AppExceptionType.remote => switch ((appException as RemoteException).kind) {
        RemoteExceptionKind.badCertificate => S.current.badCertificate,
        RemoteExceptionKind.noInternet => S.current.noInternet,
        RemoteExceptionKind.network => S.current.networkError,
        RemoteExceptionKind.serverDefined =>
          appException.generalServerMessage ?? S.current.serverDefined,
        RemoteExceptionKind.serverUndefined =>
          appException.generalServerMessage ?? S.current.serverUndefined,
        RemoteExceptionKind.timeout => S.current.timeout,
        RemoteExceptionKind.cancellation => S.current.cancelled,
        RemoteExceptionKind.unknown => S.current.unknownError,
        RemoteExceptionKind.invalidToken => S.current.invalidToken,
        RemoteExceptionKind.decodeError => S.current.decodeError,
        RemoteExceptionKind.forbidden => S.current.forbidden,
      },
      AppExceptionType.camera => switch ((appException as AppCameraException).kind) {
        AppCameraExceptionKind.cameraAccessDenied => S.current.cameraAccessDenied,
        AppCameraExceptionKind.cameraAccessDeniedWithoutPrompt =>
          S.current.cameraAccessDeniedWithoutPrompt,
        AppCameraExceptionKind.cameraAccessRestricted => S.current.cameraAccessRestricted,
        AppCameraExceptionKind.audioAccessDenied => S.current.audioAccessDenied,
        AppCameraExceptionKind.audioAccessDeniedWithoutPrompt =>
          S.current.audioAccessDeniedWithoutPrompt,
        AppCameraExceptionKind.audioAccessRestricted => S.current.audioAccessRestricted,
      },
      AppExceptionType.parse => S.current.parseError,
      AppExceptionType.uncaught => S.current.uncaughtError,
    };
  }
}
