import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late UpdateUserDefaultCurrencyUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = UpdateUserDefaultCurrencyUseCase(repository);
  });

  test('updates the default currency on the repository', () async {
    when(
      () => repository.updateUserDefaultCurrency(currencyCode: any(named: 'currencyCode')),
    ).thenAnswer((_) async {});

    await useCase.execute(const UpdateUserDefaultCurrencyInput(currencyCode: 'VND'));

    verify(() => repository.updateUserDefaultCurrency(currencyCode: 'VND')).called(1);
  });
}
