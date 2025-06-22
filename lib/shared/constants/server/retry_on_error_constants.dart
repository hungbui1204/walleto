class RetryOnErrorConstants {
  const RetryOnErrorConstants._();

  static int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 3);
}
