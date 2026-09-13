import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late CreateUserByEmailUseCase useCase;

  const input = CreateUserByEmailInput(
    email: 'user@example.com',
    password: 'secret12',
    code: '123456',
  );

  setUp(() {
    repository = _MockRepository();
    useCase = CreateUserByEmailUseCase(repository);
  });

  test('forwards email, password, and OTP code to the repository', () async {
    when(
      () => repository.createUserByEmail(
        email: 'user@example.com',
        password: 'secret12',
        code: '123456',
      ),
    ).thenAnswer((_) async {});

    final output = await useCase.execute(input);

    expect(output, const CreateUserByEmailOutput());
    verify(
      () => repository.createUserByEmail(
        email: 'user@example.com',
        password: 'secret12',
        code: '123456',
      ),
    ).called(1);
  });

  test('propagates AppException from the repository', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.network);
    when(
      () => repository.createUserByEmail(
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
      () => repository.createUserByEmail(
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
