class AuthSessionConstants {
  const AuthSessionConstants._();

  static const refreshSafetyWindow = Duration(seconds: 45);
  static const rejectedRefreshTokenErrorCodes = <String>{
    'refresh_token_not_found',
    'refresh_token_already_used',
    'session_not_found',
    'session_expired',
  };

  static bool isRejectedRefreshToken({required int? httpStatusCode, required String? errorCode}) {
    return (httpStatusCode == 400 || httpStatusCode == 401 || httpStatusCode == 422) &&
        rejectedRefreshTokenErrorCodes.contains(errorCode?.toLowerCase());
  }
}
