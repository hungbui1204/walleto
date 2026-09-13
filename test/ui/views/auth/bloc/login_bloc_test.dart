import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockLoginByPasswordUseCase extends Mock implements LoginByPasswordUseCase {}

class _MockCreateUserByEmailUseCase extends Mock implements CreateUserByEmailUseCase {}

class _MockVerifyOtpForEmailUseCase extends Mock implements VerifyOtpForEmailUseCase {}

class _MockSendOtpForEmailCheckingUseCase extends Mock implements SendOtpForEmailCheckingUseCase {}

class _MockGetWalletsUseCase extends Mock implements GetWalletsUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  late _MockLoginByPasswordUseCase loginByPasswordUseCase;
  late _MockCreateUserByEmailUseCase createUserByEmailUseCase;
  late _MockVerifyOtpForEmailUseCase verifyOtpForEmailUseCase;
  late _MockSendOtpForEmailCheckingUseCase sendOtpForEmailCheckingUseCase;
  late _MockGetWalletsUseCase getWalletsUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  LoginBloc buildBloc() {
    return LoginBloc(
        loginByPasswordUseCase,
        createUserByEmailUseCase,
        verifyOtpForEmailUseCase,
        sendOtpForEmailCheckingUseCase,
        getWalletsUseCase,
      )
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(
      const CreateUserByEmailInput(email: 'a@b.c', password: 'pw', code: '000000'),
    );
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    loginByPasswordUseCase = _MockLoginByPasswordUseCase();
    createUserByEmailUseCase = _MockCreateUserByEmailUseCase();
    verifyOtpForEmailUseCase = _MockVerifyOtpForEmailUseCase();
    sendOtpForEmailCheckingUseCase = _MockSendOtpForEmailCheckingUseCase();
    getWalletsUseCase = _MockGetWalletsUseCase();
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
    when(
      () => createUserByEmailUseCase.execute(any()),
    ).thenAnswer((_) async => const CreateUserByEmailOutput());
  });

  blocTest<LoginBloc, LoginState>(
    'sends the in-memory OTP with email and password when sign-up is confirmed',
    build: buildBloc,
    seed:
        () => const LoginState(
          signUpEmail: 'user@example.com',
          signUpPassword: 'secret12',
          otp: '123456',
          isCheckedAcceptTerms: true,
        ),
    act: (bloc) => bloc.add(const SignUpConfirmButtonPressed()),
    expect:
        () => const [
          LoginState(
            signUpEmail: 'user@example.com',
            signUpPassword: 'secret12',
            otp: '123456',
            isCheckedAcceptTerms: true,
            signUpStep: SignUpStep.signUpComplete,
          ),
        ],
    verify: (_) {
      verify(
        () => createUserByEmailUseCase.execute(
          const CreateUserByEmailInput(
            email: 'user@example.com',
            password: 'secret12',
            code: '123456',
          ),
        ),
      ).called(1);
    },
  );
}
