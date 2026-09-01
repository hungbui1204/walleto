import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late GetWalletsUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetWalletsUseCase(repository);
  });

  test('returns wallets from the repository', () async {
    const wallets = [
      Wallet(id: 1, name: 'Cash', amount: 100, currencyCode: 'USD'),
      Wallet(id: 2, name: 'Bank', amount: 500, currencyCode: 'USD'),
    ];
    when(() => repository.getWallets()).thenAnswer((_) async => wallets);

    final output = await useCase.execute(const GetWalletsInput());

    expect(output.wallets, wallets);
    verify(() => repository.getWallets()).called(1);
  });

  test('propagates AppException from the repository', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.network);
    when(() => repository.getWallets()).thenThrow(exception);

    await expectLater(useCase.execute(const GetWalletsInput()), throwsA(same(exception)));
    verify(() => repository.getWallets()).called(1);
  });

  test('wraps a non-AppException in AppUncaughtException', () async {
    final cause = StateError('boom');
    when(() => repository.getWallets()).thenThrow(cause);

    await expectLater(
      useCase.execute(const GetWalletsInput()),
      throwsA(isA<AppUncaughtException>().having((e) => e.rootError, 'rootError', same(cause))),
    );
    verify(() => repository.getWallets()).called(1);
  });
}
