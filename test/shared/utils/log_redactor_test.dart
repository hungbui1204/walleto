import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _LoginPasswordInputChanged {
  const _LoginPasswordInputChanged(this.password);

  final String password;

  @override
  String toString() => 'LoginPasswordInputChanged(password: $password)';
}

class _SignUpConfirmPasswordInputChanged {
  const _SignUpConfirmPasswordInputChanged();
}

class _ResetPasswordConfirmEmailButtonPressed {
  const _ResetPasswordConfirmEmailButtonPressed();
}

class _HomeViewInitiated {
  const _HomeViewInitiated();
}

void main() {
  group('LogRedactor.redact', () {
    test('replaces password, tokens, and Authorization; keeps other fields', () {
      final redacted =
          LogRedactor.redact({
                'email': 'user@example.com',
                'password': 'super-secret',
                'Authorization': 'Bearer abc.def',
                'refresh_token': 'refresh-secret',
                'access_token': 'access-secret',
                'apiKey': 'env-api-key',
                'otp': '123456',
                'code': '654321',
                'grant_type': 'password',
                'nested': {'refreshToken': 'nested-secret', 'id': 1},
              })
              as Map<String, dynamic>;

      expect(redacted['email'], 'user@example.com');
      expect(redacted['password'], LogRedactor.placeholder);
      expect(redacted['Authorization'], LogRedactor.placeholder);
      expect(redacted['refresh_token'], LogRedactor.placeholder);
      expect(redacted['access_token'], LogRedactor.placeholder);
      expect(redacted['apiKey'], LogRedactor.placeholder);
      expect(redacted['otp'], LogRedactor.placeholder);
      expect(redacted['code'], LogRedactor.placeholder);
      expect(redacted['grant_type'], 'password');
      expect((redacted['nested'] as Map<String, dynamic>)['refreshToken'], LogRedactor.placeholder);
      expect((redacted['nested'] as Map<String, dynamic>)['id'], 1);
    });

    test('parses JSON string bodies before redacting', () {
      final redacted =
          LogRedactor.redact('{"email":"a@b.c","password":"secret"}') as Map<String, dynamic>;

      expect(redacted['email'], 'a@b.c');
      expect(redacted['password'], LogRedactor.placeholder);
    });

    test('redacts chat content and user notes in request and response payloads', () {
      final redacted =
          LogRedactor.redact({
                'message': 'private chat message',
                'messages': [
                  {'role': 'user', 'content': 'private response content'},
                ],
                'conversation': [
                  {'role': 'assistant', 'content': 'private streamed content'},
                ],
                'note': 'private transaction note',
              })
              as Map<String, dynamic>;

      expect(redacted['message'], LogRedactor.placeholder);
      expect(redacted['messages'], LogRedactor.placeholder);
      expect((redacted['conversation'] as List).single['content'], LogRedactor.placeholder);
      expect(redacted['note'], LogRedactor.placeholder);
      expect(LogRedactor.stringify(redacted), isNot(contains('private')));
    });
  });

  group('LogRedactor.stringify', () {
    test('does not print secret values', () {
      final output = LogRedactor.stringify({
        'password': 'super-secret',
        'Authorization': 'Bearer abc.def',
        'refresh_token': 'refresh-secret',
      });

      expect(output, isNot(contains('super-secret')));
      expect(output, isNot(contains('Bearer abc.def')));
      expect(output, isNot(contains('refresh-secret')));
      expect(output, contains(LogRedactor.placeholder));
    });
  });

  group('LogRedactor.forEvent', () {
    test('redacts password-bearing event types without printing the password', () {
      const event = _LoginPasswordInputChanged('super-secret');

      expect(LogRedactor.isPasswordBearingEvent(event), isTrue);
      expect(LogRedactor.forEvent(event), isNot(contains('super-secret')));
      expect(LogRedactor.forEvent(event), contains(LogRedactor.placeholder));
    });

    test('redacts confirm-password events and keeps other ResetPassword events', () {
      expect(
        LogRedactor.isPasswordBearingEvent(const _SignUpConfirmPasswordInputChanged()),
        isTrue,
      );
      expect(
        LogRedactor.isPasswordBearingEvent(const _ResetPasswordConfirmEmailButtonPressed()),
        isFalse,
      );
      expect(LogRedactor.isPasswordBearingEvent(const _HomeViewInitiated()), isFalse);
      expect(
        LogRedactor.forEvent(const _HomeViewInitiated()),
        isNot(contains(LogRedactor.placeholder)),
      );
    });

    test('redacts submitted AI chat text', () {
      const event = AiChatMessageSubmitted(message: 'private chat message');

      expect(LogRedactor.isMessageBearingEvent(event), isTrue);
      expect(LogRedactor.forEvent(event), isNot(contains('private chat message')));
      expect(LogRedactor.forEvent(event), contains(LogRedactor.placeholder));
    });

    test('redacts transaction notes from BLoC event logs', () {
      const event = CreateTransactionNoteChanged(note: 'private transaction note');

      expect(LogRedactor.forEvent(event), isNot(contains('private transaction note')));
      expect(LogRedactor.forEvent(event), contains(LogRedactor.placeholder));
    });

    test('redacts OTP from reset-password input event logs', () {
      const event = ResetPasswordOtpInputChanged(otp: '914207');

      expect(LogRedactor.forEvent(event), isNot(contains('914207')));
      expect(LogRedactor.forEvent(event), contains(LogRedactor.placeholder));
    });
  });
}
