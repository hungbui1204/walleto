import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockSendOtpForResetPasswordUseCase extends Mock implements SendOtpForResetPasswordUseCase {}

class _MockVerifyOtpForResetPasswordUseCase extends Mock
    implements VerifyOtpForResetPasswordUseCase {}

class _MockResetUserPasswordUseCase extends Mock implements ResetUserPasswordUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  late _MockSendOtpForResetPasswordUseCase sendOtpForResetPasswordUseCase;
  late _MockVerifyOtpForResetPasswordUseCase verifyOtpForResetPasswordUseCase;
  late _MockResetUserPasswordUseCase resetUserPasswordUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  ResetPasswordBloc buildBloc() {
    return ResetPasswordBloc(
        sendOtpForResetPasswordUseCase,
        verifyOtpForResetPasswordUseCase,
        resetUserPasswordUseCase,
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
      const ResetUserPasswordInput(email: 'a@b.c', password: 'pw', code: '000000'),
    );
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    sendOtpForResetPasswordUseCase = _MockSendOtpForResetPasswordUseCase();
    verifyOtpForResetPasswordUseCase = _MockVerifyOtpForResetPasswordUseCase();
    resetUserPasswordUseCase = _MockResetUserPasswordUseCase();
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
      () => resetUserPasswordUseCase.execute(any()),
    ).thenAnswer((_) async => const ResetUserPasswordOutput());
  });

  blocTest<ResetPasswordBloc, ResetPasswordState>(
    'sends the in-memory OTP with email and password when reset is confirmed',
    build: buildBloc,
    seed:
        () => const ResetPasswordState(
          email: 'user@example.com',
          password: 'secret12',
          otp: '654321',
        ),
    act: (bloc) => bloc.add(const ResetPasswordButtonPressed()),
    expect:
        () => const [
          ResetPasswordState(
            email: 'user@example.com',
            password: 'secret12',
            otp: '654321',
            resetPasswordStep: ResetPasswordStep.resetPasswordComplete,
          ),
        ],
    verify: (_) {
      verify(
        () => resetUserPasswordUseCase.execute(
          const ResetUserPasswordInput(
            email: 'user@example.com',
            password: 'secret12',
            code: '654321',
          ),
        ),
      ).called(1);
    },
  );
}
