import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class ExceptionMessageMapper {
  const ExceptionMessageMapper();

  String map(AppException appException) {
    return switch (appException.appExceptionType) {
      AppExceptionType.remote => switch ((appException as RemoteException).kind) {
        RemoteExceptionKind.badCertificate => '',
        RemoteExceptionKind.noInternet => '',
        RemoteExceptionKind.network => '',
        RemoteExceptionKind.serverDefined => appException.generalServerMessage ?? '',
        RemoteExceptionKind.serverUndefined => appException.generalServerMessage ?? '',
        RemoteExceptionKind.timeout => '',
        RemoteExceptionKind.cancellation => '',
        RemoteExceptionKind.unknown => '',
        RemoteExceptionKind.invalidToken => '',
        RemoteExceptionKind.decodeError => '',
        RemoteExceptionKind.forbidden => '403 Forbidden error',
      },
      AppExceptionType.camera => switch ((appException as AppCameraException).kind) {
        AppCameraExceptionKind.cameraAccessDenied => '',
        AppCameraExceptionKind.cameraAccessDeniedWithoutPrompt => '',
        AppCameraExceptionKind.cameraAccessRestricted => '',
        AppCameraExceptionKind.audioAccessDenied => '',
        AppCameraExceptionKind.audioAccessDeniedWithoutPrompt => '',
        AppCameraExceptionKind.audioAccessRestricted => '',
      },
      AppExceptionType.parse => '',
      AppExceptionType.uncaught => '',
    };
  }
}
