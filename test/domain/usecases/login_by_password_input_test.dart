import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

void main() {
  test('LoginByPasswordInput.toString redacts password and keeps email', () {
    const input = LoginByPasswordInput(
      email: 'user@example.com',
      password: 'super-secret',
      fcmToken: 'fcm-token',
      timezone: 'UTC',
    );

    expect(input.toString(), isNot(contains('super-secret')));
    expect(input.toString(), contains(LogRedactor.placeholder));
    expect(input.toString(), contains('user@example.com'));
    expect(input.password, 'super-secret');
  });
}
