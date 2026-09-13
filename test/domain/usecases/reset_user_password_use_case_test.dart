import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late ResetUserPasswordUseCase useCase;

  const input = ResetUserPasswordInput(
    email: 'user@example.com',
    password: 'secret12',
    code: '654321',
  );

  setUp(() {
    repository = _MockRepository();
    useCase = ResetUserPasswordUseCase(repository);
  });

  test('forwards email, password, and OTP code to the repository', () async {
    when(
      () => repository.resetUserPassword(
        email: 'user@example.com',
        password: 'secret12',
        code: '654321',
      ),
    ).thenAnswer((_) async {});

    final output = await useCase.execute(input);

    expect(output, const ResetUserPasswordOutput());
    verify(
      () => repository.resetUserPassword(
        email: 'user@example.com',
        password: 'secret12',
        code: '654321',
      ),
    ).called(1);
  });

  test('propagates AppException from the repository', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.serverDefined);
    when(
      () => repository.resetUserPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
        code: any(named: 'code'),
      ),
    ).thenThrow(exception);

    await expectLater(useCase.execute(input), throwsA(same(exception)));
  });

  test('wraps a non-AppException in AppUncaughtException', () async {
    final cause = StateError('boom');
    when(
      () => repository.resetUserPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
        code: any(named: 'code'),
      ),
    ).thenThrow(cause);

    await expectLater(
      useCase.execute(input),
      throwsA(isA<AppUncaughtException>().having((e) => e.rootError, 'rootError', same(cause))),
    );
  });
}
