import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late InvalidTokenHandleUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = InvalidTokenHandleUseCase(repository, RefreshTokenManager(repository));
  });

  test('returns emptyToken when the user is not logged in', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => false);

    final output = await useCase.execute(const InvalidTokenHandleInput());

    expect(output.status, InvalidTokenHandlerStatus.emptyToken);
  });

  test('returns tokenRefreshed when refresh succeeds', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(
      () => repository.refreshAuthToken(refreshToken: any(named: 'refreshToken')),
    ).thenAnswer((_) async => const Authentication());

    final output = await useCase.execute(const InvalidTokenHandleInput());

    expect(output.status, InvalidTokenHandlerStatus.tokenRefreshed);
  });

  test('returns refreshTokenExpired on 401 from refresh', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(() => repository.refreshAuthToken(refreshToken: any(named: 'refreshToken'))).thenThrow(
      const RemoteException(
        kind: RemoteExceptionKind.invalidToken,
        httpErrorCode: HttpStatus.unauthorized,
      ),
    );

    final output = await useCase.execute(const InvalidTokenHandleInput());

    expect(output.status, InvalidTokenHandlerStatus.refreshTokenExpired);
  });

  test('returns refreshFailed on non-401 refresh errors', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(() => repository.refreshAuthToken(refreshToken: any(named: 'refreshToken'))).thenThrow(
      const RemoteException(kind: RemoteExceptionKind.serverUndefined, httpErrorCode: 500),
    );

    final output = await useCase.execute(const InvalidTokenHandleInput());

    expect(output.status, InvalidTokenHandlerStatus.refreshFailed);
  });
}
