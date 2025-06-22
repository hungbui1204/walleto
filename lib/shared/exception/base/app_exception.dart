abstract class AppException implements Exception {
  const AppException(this.appExceptionType);

  final AppExceptionType appExceptionType;
}

enum AppExceptionType {
  remote,
  parse,
  uncaught,
  camera,
}
