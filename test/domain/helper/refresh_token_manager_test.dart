import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late RefreshTokenManager manager;

  setUp(() {
    repository = _MockRepository();
    manager = RefreshTokenManager(repository, AuthSessionCoordinator());
  });

  test('does not refresh a session with a safe expiry window', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(
      () => repository.sessionExpiresAt,
    ).thenAnswer((_) async => DateTime.now().add(const Duration(minutes: 3)));

    expect(await manager.ensureFreshSession(), isTrue);
    verifyNever(() => repository.refreshToken);
  });

  test('refreshes an expired session and retains the session on network failure', () async {
    const error = RemoteException(kind: RemoteExceptionKind.network);
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.sessionExpiresAt).thenAnswer((_) async => null);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(() => repository.refreshAuthToken(refreshToken: 'refresh-token')).thenThrow(error);
    when(() => repository.clearInvalidSession()).thenAnswer((_) async {});

    await expectLater(manager.ensureFreshSession(), throwsA(same(error)));
    verifyNever(() => repository.clearInvalidSession());
  });

  test('clears a session when Supabase rejects the refresh token with HTTP 400', () async {
    const error = RemoteException(
      kind: RemoteExceptionKind.serverDefined,
      httpErrorCode: 400,
      serverError: ServerError(generalServerErrorId: 'refresh_token_already_used'),
    );
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.sessionExpiresAt).thenAnswer((_) async => null);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(() => repository.refreshAuthToken(refreshToken: 'refresh-token')).thenThrow(error);
    when(() => repository.clearInvalidSession()).thenAnswer((_) async {});

    expect(await manager.ensureFreshSession(), isFalse);
    verify(() => repository.clearInvalidSession()).called(1);
  });

  test('retains the session for an unrecognized HTTP 401 refresh error', () async {
    const error = RemoteException(kind: RemoteExceptionKind.serverDefined, httpErrorCode: 401);
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.sessionExpiresAt).thenAnswer((_) async => null);
    when(() => repository.refreshToken).thenAnswer((_) async => 'refresh-token');
    when(() => repository.refreshAuthToken(refreshToken: 'refresh-token')).thenThrow(error);
    when(() => repository.clearInvalidSession()).thenAnswer((_) async {});

    await expectLater(manager.ensureFreshSession(), throwsA(same(error)));
    verifyNever(() => repository.clearInvalidSession());
  });
}
