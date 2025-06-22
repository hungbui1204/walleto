import 'package:walleto/shared/shared.dart';

class AppCameraException extends AppException {
  const AppCameraException(this.kind) : super(AppExceptionType.camera);

  final AppCameraExceptionKind kind;

  @override
  String toString() {
    return 'AppCameraException: {kind: $kind}';
  }
}

enum AppCameraExceptionKind {
  cameraAccessDenied,
  cameraAccessDeniedWithoutPrompt,
  cameraAccessRestricted,
  audioAccessDenied,
  audioAccessDeniedWithoutPrompt,
  audioAccessRestricted,
}
