import 'dart:convert';

/// Redacts secrets from debug logs. Does not disable logging.
class LogRedactor {
  const LogRedactor._();

  static const placeholder = '[redacted]';

  static const _prettyIndent = '    ';

  static const _sensitiveKeys = {
    'authorization',
    'password',
    'confirmpassword',
    'refreshtoken',
    'accesstoken',
    'idtoken',
    'apikey',
    'secret',
    'clientsecret',
  };

  static bool isSensitiveKey(Object? key) {
    if (key == null) {
      return false;
    }

    final normalized = _normalizeKey(key);
    return _sensitiveKeys.contains(normalized) || normalized.contains('password');
  }

  /// True when a BLoC event type name carries a password field.
  ///
  /// Matches `*PasswordInput*` / `*ConfirmPassword*` without flagging every
  /// `ResetPassword*` event (confirm-email, resend OTP, …).
  static bool isPasswordBearingEvent(Object? event) {
    if (event == null) {
      return false;
    }

    final typeName = event.runtimeType.toString().toLowerCase();
    return typeName.contains('passwordinput') || typeName.contains('confirmpassword');
  }

  static String forEvent(Object? event) {
    if (event == null) {
      return 'null';
    }
    if (isPasswordBearingEvent(event)) {
      return '${event.runtimeType}($placeholder)';
    }

    return event.toString();
  }

  static dynamic redact(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): isSensitiveKey(entry.key) ? placeholder : redact(entry.value),
      };
    }

    if (value is Iterable && value is! String) {
      return [for (final item in value) redact(item)];
    }

    if (value is String) {
      final trimmed = value.trimLeft();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          return redact(jsonDecode(value));
        } on FormatException {
          return value;
        }
      }
    }

    return value;
  }

  static String stringify(dynamic data) {
    final redacted = redact(data);
    try {
      if (redacted is Map || redacted is List) {
        return const JsonEncoder.withIndent(_prettyIndent).convert(redacted);
      }
    } on Object {
      // Fall back when a value is not JSON-encodable.
    }

    return redacted.toString();
  }

  static String _normalizeKey(Object key) {
    return key.toString().toLowerCase().replaceAll(RegExp(r'[-_\s]'), '');
  }
}
