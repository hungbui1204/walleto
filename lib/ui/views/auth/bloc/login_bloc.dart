import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  LoginBloc(
    this._loginByPasswordUseCase,
    this._createUserByEmailUseCase,
    this._verifyOtpForEmailUseCase,
    this._sendOtpForEmailCheckingUseCase,
  ) : super(const LoginState()) {
    on<LoginEmailInputChanged>(_onEmailInputChanged, transformer: log());
    on<LoginPasswordInputChanged>(_onPasswordInputChanged, transformer: log());
    on<SignInButtonPressed>(_onSignInButtonPressed, transformer: log());
    on<SignUpEmailInputChanged>(_onSignUpEmailInputChanged, transformer: log());
    on<ConfirmEmailSignUpButtonPressed>(_onConfirmEmailSignUpButtonPressed, transformer: log());
    on<SignUpBackToPreviousStepButtonPressed>(
      _onSignUpBackToPreviousStepButtonPressed,
      transformer: log(),
    );
    on<SignUpOtpInputChanged>(_onSignUpOtpInputChanged, transformer: log());
    on<ConfirmOtpSignUpButtonPressed>(_onConfirmOtpSignUpButtonPressed, transformer: log());
    on<SignUpRemainingSecondsForReSendOtpChanged>(
      _onSignUpRemainingSecondsForReSendOtpChanged,
      transformer: log(),
    );
    on<SignUpResendOtpButtonPressed>(_onSignUpResendOtpButtonPressed, transformer: log());
    on<SignUpPasswordInputChanged>(_onSignUpPasswordInputChanged, transformer: log());
    on<SignUpConfirmPasswordInputChanged>(_onSignUpConfirmPasswordInputChanged, transformer: log());
    on<SignUpConfirmButtonPressed>(_onSignUpConfirmButtonPressed, transformer: log());
    on<SignUpAcceptTermsCheckboxToggled>(_onSignUpAcceptTermsCheckboxToggled, transformer: log());
  }

  final LoginByPasswordUseCase _loginByPasswordUseCase;
  final CreateUserByEmailUseCase _createUserByEmailUseCase;
  final VerifyOtpForEmailUseCase _verifyOtpForEmailUseCase;
  final SendOtpForEmailCheckingUseCase _sendOtpForEmailCheckingUseCase;
  Timer? _reSendOtpTimer;

  @override
  Future<void> close() {
    _reSendOtpTimer?.cancel();
    return super.close();
  }

  bool _loginButtonEnable({required String email, required String password}) {
    return email.isNotEmpty && password.isNotEmpty;
  }

  bool _signUpConfirmButtonEnable({
    required String email,
    required String password,
    required String confirmPassword,
    required bool isCheckedAcceptTerms,
  }) {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        isCheckedAcceptTerms &&
        password == confirmPassword;
  }

  bool _confirmEmailButtonEnable({required String email, required int counter}) {
    // Enable the button if email is not empty and the timer has finished
    return email.isNotEmpty && counter == 0;
  }

  bool _confirmOtpButtonEnable(String otp) {
    return otp.length == 6;
  }

  void _startTimerForReSendOtp() {
    _reSendOtpTimer?.cancel();

    int remainingSecondsForReSendOtp = DurationConstants.defaultReSendOtpDuration.inSeconds;

    // Initialize the remaining seconds for re-send OTP
    add(SignUpRemainingSecondsForReSendOtpChanged(seconds: remainingSecondsForReSendOtp));

    // Start a periodic timer that ticks every second
    _reSendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSecondsForReSendOtp--;

      // Update the remaining seconds for re-send OTP
      add(SignUpRemainingSecondsForReSendOtpChanged(seconds: remainingSecondsForReSendOtp));

      if (remainingSecondsForReSendOtp == 0) {
        timer.cancel();
      }
    });
  }

  void _onEmailInputChanged(LoginEmailInputChanged event, Emitter<LoginState> emit) {
    if (event.email.isEmpty) {
      emit(state.copyWith(emailError: S.current.emailRequired));
    } else {
      emit(state.copyWith(emailError: ''));
    }

    emit(
      state.copyWith(
        email: event.email,
        isEnableLoginButton: _loginButtonEnable(email: event.email, password: state.password),
      ),
    );
  }

  void _onPasswordInputChanged(LoginPasswordInputChanged event, Emitter<LoginState> emit) {
    if (event.password.isEmpty) {
      emit(state.copyWith(passwordError: S.current.passwordRequired));
    } else {
      emit(state.copyWith(passwordError: ''));
    }

    emit(
      state.copyWith(
        password: event.password,
        isEnableLoginButton: _loginButtonEnable(email: state.email, password: event.password),
      ),
    );
  }

  Future<void> _onSignInButtonPressed(SignInButtonPressed event, Emitter<LoginState> emit) async {
    await runBlocCatching(
      action: () async {
        // Validate email format
        if (!RegexConstants.email.hasMatch(state.email)) {
          emit(state.copyWith(emailError: S.current.invalidEmailFormat));

          return;
        }

        final fcmToken = await FirebaseMessaging.instance.getToken();

        tz.initializeTimeZones();
        final location = tz.local;
        final timeZoneName = location.name;

        await _loginByPasswordUseCase.execute(
          LoginByPasswordInput(
            email: state.email,
            password: state.password,
            fcmToken: fcmToken ?? '',
            timezone: timeZoneName,
          ),
        );

        navigator.replace(const AppRouteInfo.main());
      },
    );
  }

  void _onSignUpEmailInputChanged(SignUpEmailInputChanged event, Emitter<LoginState> emit) {
    if (event.email.isEmpty) {
      emit(state.copyWith(signUpEmailError: S.current.emailRequired));
    } else {
      emit(state.copyWith(signUpEmailError: ''));
    }

    emit(
      state.copyWith(
        signUpEmail: event.email,
        isEnableConfirmEmailSignUpButton: _confirmEmailButtonEnable(
          email: event.email,
          counter: state.remainingSecondsForReSendOtp,
        ),
      ),
    );
  }

  Future<void> _onConfirmEmailSignUpButtonPressed(
    ConfirmEmailSignUpButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        // Validate email format
        if (!RegexConstants.email.hasMatch(state.signUpEmail)) {
          emit(state.copyWith(signUpEmailError: S.current.invalidEmailFormat));

          return;
        }

        await _sendOtpForEmailCheckingUseCase.execute(
          SendOtpForEmailCheckingInput(email: state.signUpEmail),
        );

        // Start timer for re-send OTP
        _startTimerForReSendOtp();

        emit(state.copyWith(signUpStep: SignUpStep.otpConfirm));
      },
    );
  }

  void _onSignUpBackToPreviousStepButtonPressed(
    SignUpBackToPreviousStepButtonPressed event,
    Emitter<LoginState> emit,
  ) {
    // Clear all data and go back to the first step
    emit(
      state.copyWith(
        signUpStep: SignUpStep.emailConfirm,
        signUpEmail: '',
        signUpPassword: '',
        signUpConfirmPassword: '',
        otp: '',
        isEnableConfirmEmailSignUpButton: false,
        isEnableConfirmOtpSignUpButton: false,
        isEnableSignUpButton: false,
      ),
    );
  }

  void _onSignUpOtpInputChanged(SignUpOtpInputChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        otp: event.otp,
        isEnableConfirmOtpSignUpButton: _confirmOtpButtonEnable(event.otp),
      ),
    );
  }

  Future<void> _onConfirmOtpSignUpButtonPressed(
    ConfirmOtpSignUpButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _verifyOtpForEmailUseCase.execute(
          VerifyOtpForEmailInput(email: state.signUpEmail, otp: state.otp),
        );

        emit(state.copyWith(signUpStep: SignUpStep.signingUp));
      },
    );
  }

  void _onSignUpRemainingSecondsForReSendOtpChanged(
    SignUpRemainingSecondsForReSendOtpChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        remainingSecondsForReSendOtp: event.seconds,
        isEnableConfirmEmailSignUpButton: _confirmEmailButtonEnable(
          email: state.signUpEmail,
          counter: event.seconds,
        ),
      ),
    );
  }

  Future<void> _onSignUpResendOtpButtonPressed(
    SignUpResendOtpButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _sendOtpForEmailCheckingUseCase.execute(
          SendOtpForEmailCheckingInput(email: state.signUpEmail),
        );

        // Restart timer for re-send OTP
        _startTimerForReSendOtp();
      },
    );
  }

  void _onSignUpPasswordInputChanged(SignUpPasswordInputChanged event, Emitter<LoginState> emit) {
    if (event.password.isEmpty) {
      emit(state.copyWith(signUpPasswordError: S.current.passwordRequired));
    } else {
      emit(state.copyWith(signUpPasswordError: ''));
    }

    emit(
      state.copyWith(
        signUpPassword: event.password,
        isEnableSignUpButton: _signUpConfirmButtonEnable(
          email: state.signUpEmail,
          password: event.password,
          confirmPassword: state.signUpConfirmPassword,
          isCheckedAcceptTerms: state.isCheckedAcceptTerms,
        ),
      ),
    );
  }

  void _onSignUpConfirmPasswordInputChanged(
    SignUpConfirmPasswordInputChanged event,
    Emitter<LoginState> emit,
  ) {
    if (event.confirmPassword != state.signUpPassword) {
      emit(state.copyWith(signUpConfirmPasswordError: S.current.confirmPasswordDoesNotMatch));
    } else {
      emit(state.copyWith(signUpConfirmPasswordError: ''));
    }

    emit(
      state.copyWith(
        signUpConfirmPassword: event.confirmPassword,
        isEnableSignUpButton: _signUpConfirmButtonEnable(
          email: state.signUpEmail,
          password: state.signUpPassword,
          confirmPassword: event.confirmPassword,
          isCheckedAcceptTerms: state.isCheckedAcceptTerms,
        ),
      ),
    );
  }

  Future<void> _onSignUpConfirmButtonPressed(
    SignUpConfirmButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _createUserByEmailUseCase.execute(
          CreateUserByEmailInput(email: state.signUpEmail, password: state.signUpPassword),
        );

        emit(state.copyWith(signUpStep: SignUpStep.signUpComplete));
      },
    );
  }

  void _onSignUpAcceptTermsCheckboxToggled(
    SignUpAcceptTermsCheckboxToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        isCheckedAcceptTerms: !state.isCheckedAcceptTerms,
        isEnableSignUpButton: _signUpConfirmButtonEnable(
          email: state.signUpEmail,
          password: state.signUpPassword,
          confirmPassword: state.signUpConfirmPassword,
          isCheckedAcceptTerms: !state.isCheckedAcceptTerms,
        ),
      ),
    );
  }
}
