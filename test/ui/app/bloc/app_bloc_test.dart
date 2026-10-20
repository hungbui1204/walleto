import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockSignOutUseCase extends Mock implements SignOutUseCase {}

class _MockGetWalletsUseCase extends Mock implements GetWalletsUseCase {}

class _MockGetCurrenciesUseCase extends Mock implements GetCurrenciesUseCase {}

class _MockGetUserDefaultCurrencyUseCase extends Mock implements GetUserDefaultCurrencyUseCase {}

class _MockUpdateUserDefaultCurrencyUseCase extends Mock
    implements UpdateUserDefaultCurrencyUseCase {}

class _MockSetAppThemePreferenceUseCase extends Mock implements SetAppThemePreferenceUseCase {}

class _MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const wallet = Wallet(id: 1, name: 'Cash', amount: 50, currencyCode: 'USD');

  late _MockSignOutUseCase signOutUseCase;
  late _MockGetWalletsUseCase getWalletsUseCase;
  late _MockGetCurrenciesUseCase getCurrenciesUseCase;
  late _MockGetUserDefaultCurrencyUseCase getUserDefaultCurrencyUseCase;
  late _MockUpdateUserDefaultCurrencyUseCase updateUserDefaultCurrencyUseCase;
  late _MockSetAppThemePreferenceUseCase setAppThemePreferenceUseCase;
  late _MockIsLoggedInUseCase isLoggedInUseCase;
  late _MockAppNavigator navigator;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  AppBloc buildBloc() {
    return AppBloc(
        signOutUseCase,
        getWalletsUseCase,
        getCurrenciesUseCase,
        getUserDefaultCurrencyUseCase,
        updateUserDefaultCurrencyUseCase,
        setAppThemePreferenceUseCase,
        isLoggedInUseCase,
      )
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const GetWalletsInput());
    registerFallbackValue(const GetUserDefaultCurrencyInput());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    signOutUseCase = _MockSignOutUseCase();
    getWalletsUseCase = _MockGetWalletsUseCase();
    getCurrenciesUseCase = _MockGetCurrenciesUseCase();
    getUserDefaultCurrencyUseCase = _MockGetUserDefaultCurrencyUseCase();
    updateUserDefaultCurrencyUseCase = _MockUpdateUserDefaultCurrencyUseCase();
    setAppThemePreferenceUseCase = _MockSetAppThemePreferenceUseCase();
    isLoggedInUseCase = _MockIsLoggedInUseCase();
    navigator = _MockAppNavigator();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(
      () => getUserDefaultCurrencyUseCase.execute(any()),
    ).thenAnswer((_) async => const GetUserDefaultCurrencyOutput());
  });

  test('wallet refresh waits for its fetch despite unrelated AppBloc states', () async {
    final fetchStarted = Completer<void>();
    final walletResponse = Completer<GetWalletsOutput>();
    when(() => getWalletsUseCase.execute(any())).thenAnswer((_) {
      if (!fetchStarted.isCompleted) fetchStarted.complete();
      return walletResponse.future;
    });

    final bloc = buildBloc();
    final refresh = bloc.refreshWallets();
    await fetchStarted.future;

    final unrelatedState = bloc.stream.firstWhere(
      (state) => state.themePreference == AppThemePreference.light,
    );
    bloc.add(const AppThemePreferenceInitialized(AppThemePreference.light));
    await unrelatedState;

    var refreshCompleted = false;
    refresh.then((_) => refreshCompleted = true);
    await Future<void>.delayed(Duration.zero);
    expect(refreshCompleted, isFalse);

    walletResponse.complete(const GetWalletsOutput(wallets: [wallet]));
    await refresh;

    expect(refreshCompleted, isTrue);
    expect(bloc.state.wallets, const [wallet]);
    await bloc.close();
  });
}
