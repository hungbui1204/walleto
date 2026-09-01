import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockCreateWalletUseCase extends Mock implements CreateWalletUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const usd = Currency(code: 'USD');
  const vnd = Currency(code: 'VND');
  const seededWallet = CreateWalletState(
    walletName: 'Cash',
    initialBalance: '150',
    iconUrl: 'https://cdn.example/wallet.png',
    selectedCurrency: usd,
  );
  const createdWallet = Wallet(
    name: 'Cash',
    amount: 150,
    iconUrl: 'https://cdn.example/wallet.png',
    currencyCode: 'USD',
  );

  late _MockCreateWalletUseCase createWalletUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  CreateWalletBloc buildBloc() {
    return CreateWalletBloc(createWalletUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const CreateWalletInput(wallet: Wallet()));
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    createWalletUseCase = _MockCreateWalletUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.state).thenReturn(const AppState());
    when(() => appBloc.add(any())).thenReturn(null);
    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(() => navigator.getCurrentRouteNames()).thenReturn(const <String?>[]);
    when(() => navigator.replace(any())).thenAnswer((_) async => null);
    when(() => navigator.pop()).thenAnswer((_) async => true);
    when(
      () => createWalletUseCase.execute(any()),
    ).thenAnswer((_) async => const CreateWalletOutput());
  });

  blocTest<CreateWalletBloc, CreateWalletState>(
    'selects the app default currency when the view is initiated',
    setUp: () {
      when(() => appBloc.state).thenReturn(const AppState(currencies: [vnd, usd]));
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const CreateWalletViewInitiated()),
    expect: () => const [CreateWalletState(selectedCurrency: usd)],
  );

  blocTest<CreateWalletBloc, CreateWalletState>(
    'creates the wallet and replaces with main when not on the wallets route',
    build: buildBloc,
    seed: () => seededWallet,
    act: (bloc) => bloc.add(const CreateWalletConfirmButtonPressed()),
    expect: () => const <CreateWalletState>[],
    verify: (_) {
      verify(
        () => createWalletUseCase.execute(const CreateWalletInput(wallet: createdWallet)),
      ).called(1);
      verify(() => navigator.replace(const AppRouteInfo.main())).called(1);
      verifyNever(() => navigator.pop());
      verifyNever(() => appBloc.add(any()));
    },
  );

  blocTest<CreateWalletBloc, CreateWalletState>(
    'forwards AppException from the use case and does not navigate',
    setUp: () {
      when(
        () => createWalletUseCase.execute(any()),
      ).thenThrow(const RemoteException(kind: RemoteExceptionKind.network));
    },
    build: buildBloc,
    seed: () => seededWallet,
    act: (bloc) => bloc.add(const CreateWalletConfirmButtonPressed()),
    expect: () => const <CreateWalletState>[],
    verify: (_) {
      final captured = verify(() => commonBloc.add(captureAny())).captured;
      final emitted = captured.whereType<ExceptionEmitted>();
      expect(emitted, hasLength(1));
      expect(
        emitted.single.appExceptionWrapper.appException,
        const RemoteException(kind: RemoteExceptionKind.network),
      );
      verifyNever(() => navigator.replace(any()));
      verifyNever(() => navigator.pop());
    },
  );
}
