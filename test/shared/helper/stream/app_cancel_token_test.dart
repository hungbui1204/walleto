import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/shared/shared.dart';

void main() {
  test('invokes listeners once when cancelled', () {
    final token = AppCancelToken();
    var calls = 0;
    token.whenCancel(() => calls += 1);

    token.cancel();
    token.cancel();

    expect(token.isCancelled, isTrue);
    expect(calls, 1);
  });

  test('invokes a listener immediately when already cancelled', () {
    final token = AppCancelToken()..cancel();
    var calls = 0;

    token.whenCancel(() => calls += 1);

    expect(calls, 1);
  });
}
