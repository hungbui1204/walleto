import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late LoadInitialResourceUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = LoadInitialResourceUseCase(repository);
  });

  test('routes to login when the user is not logged in', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => false);

    final output = await useCase.execute(const LoadInitialResourceInput());

    expect(output.initialRoutes, [InitialAppRoute.login]);
    verifyNever(() => repository.getWallets());
  });

  test('routes to create wallet when logged in with no wallets', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(() => repository.getWallets()).thenAnswer((_) async => const <Wallet>[]);

    final output = await useCase.execute(const LoadInitialResourceInput());

    expect(output.initialRoutes, [InitialAppRoute.createWallet]);
  });

  test('routes to main when logged in with wallets', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(
      () => repository.getWallets(),
    ).thenAnswer((_) async => const [Wallet(id: 1, name: 'Cash')]);

    final output = await useCase.execute(const LoadInitialResourceInput());

    expect(output.initialRoutes, [InitialAppRoute.main]);
  });

  test('routes to main when wallet fetch fails', () async {
    when(() => repository.isLoggedIn).thenAnswer((_) async => true);
    when(
      () => repository.getWallets(),
    ).thenThrow(const RemoteException(kind: RemoteExceptionKind.network));

    final output = await useCase.execute(const LoadInitialResourceInput());

    expect(output.initialRoutes, [InitialAppRoute.main]);
  });
}
