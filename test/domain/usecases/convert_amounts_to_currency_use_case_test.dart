import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late ConvertAmountsToCurrencyUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = ConvertAmountsToCurrencyUseCase(repository);
  });

  test('sums same-currency amounts without fetching a rate', () async {
    final output = await useCase.execute(
      const ConvertAmountsToCurrencyInput(
        targetCurrencyCode: 'USD',
        amounts: [
          AmountInCurrency(amount: 10, currencyCode: 'USD'),
          AmountInCurrency(amount: 5, currencyCode: 'USD', sign: -1),
        ],
      ),
    );

    expect(output.total, 5);
    verifyNever(
      () => repository.getExchangeRate(
        fromCurrencyCode: any(named: 'fromCurrencyCode'),
        toCurrencyCode: any(named: 'toCurrencyCode'),
      ),
    );
  });

  test('converts mixed currencies with a cached rate per pair', () async {
    when(
      () => repository.getExchangeRate(fromCurrencyCode: 'VND', toCurrencyCode: 'USD'),
    ).thenAnswer((_) async => const ExchangeRate(rate: 0.00004));

    final output = await useCase.execute(
      const ConvertAmountsToCurrencyInput(
        targetCurrencyCode: 'USD',
        amounts: [
          AmountInCurrency(amount: 100, currencyCode: 'USD'),
          AmountInCurrency(amount: 25000, currencyCode: 'VND'),
          AmountInCurrency(amount: 25000, currencyCode: 'VND', sign: -1),
        ],
      ),
    );

    expect(output.total, 100);
    verify(
      () => repository.getExchangeRate(fromCurrencyCode: 'VND', toCurrencyCode: 'USD'),
    ).called(1);
  });
}
