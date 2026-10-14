import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/domain/helper/auth_session_coordinator.dart';

void main() {
  test('runs concurrent auth operations one at a time', () async {
    final coordinator = AuthSessionCoordinator();
    final firstGate = Completer<void>();
    final events = <String>[];

    final first = coordinator.runExclusive(() async {
      events.add('first-start');
      await firstGate.future;
      events.add('first-end');
    });
    final second = coordinator.runExclusive(() async {
      events.add('second-start');
    });

    await Future<void>.delayed(Duration.zero);
    expect(events, ['first-start']);

    firstGate.complete();
    await Future.wait([first, second]);

    expect(events, ['first-start', 'first-end', 'second-start']);
  });

  test('continues queued operations after an earlier operation fails', () async {
    final coordinator = AuthSessionCoordinator();
    final laterOperation = coordinator.runExclusive(() async => 'completed');

    await expectLater(
      coordinator.runExclusive<String>(() async => throw StateError('failed')),
      throwsStateError,
    );
    expect(await laterOperation, 'completed');
  });
}
