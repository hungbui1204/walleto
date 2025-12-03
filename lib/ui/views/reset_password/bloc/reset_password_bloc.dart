import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'reset_password_event.dart';
part 'reset_password_state.dart';
part 'reset_password_bloc.freezed.dart';

@injectable
class ResetPasswordBloc extends BaseBloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc(
    this._sendOtpForResetPasswordUseCase,
    this._verifyOtpForResetPasswordUseCase,
    this._resetUserPasswordUseCase,
  ) : super(const ResetPasswordState()) {
    on<ResetPasswordEmailInputChanged>(_onEmailInputChanged, transformer: log());
    on<ResetPasswordConfirmEmailButtonPressed>(_onConfirmEmailButtonPressed, transformer: log());
    on<ResetPasswordBackToPreviousStepButtonPressed>(
      _onResetPasswordBackToPreviousStepButtonPressed,
      transformer: log(),
    );
    on<ResetPasswordOtpInputChanged>(_onResetPasswordOtpInputChanged, transformer: log());
    on<ResetPasswordConfirmOtpButtonPressed>(
      _onConfirmOtpResetPasswordButtonPressed,
      transformer: log(),
    );
    on<ResetPasswordRemainingSecondsForReSendOtpChanged>(
      _onResetPasswordRemainingSecondsForReSendOtpChanged,
      transformer: log(),
    );
    on<ResetPasswordPasswordInputChanged>(_onResetPasswordPasswordInputChanged, transformer: log());
    on<ResetPasswordConfirmPasswordInputChanged>(
      _onResetPasswordConfirmPasswordInputChanged,
      transformer: log(),
    );
    on<ResetPasswordButtonPressed>(_onResetPasswordConfirmButtonPressed, transformer: log());
    on<ResetPasswordResendOtpButtonPressed>(
      _onResetPasswordResendOtpButtonPressed,
      transformer: log(),
    );
  }

  final SendOtpForResetPasswordUseCase _sendOtpForResetPasswordUseCase;
  final VerifyOtpForResetPasswordUseCase _verifyOtpForResetPasswordUseCase;
  final ResetUserPasswordUseCase _resetUserPasswordUseCase;

  Timer? _reSendOtpTimer;

  @override
  Future<void> close() {
    _reSendOtpTimer?.cancel();
    return super.close();
  }

  bool _resetPasswordConfirmButtonEnable({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
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
    add(ResetPasswordRemainingSecondsForReSendOtpChanged(seconds: remainingSecondsForReSendOtp));

    // Start a periodic timer that ticks every second
    _reSendOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingSecondsForReSendOtp--;

      // Update the remaining seconds for re-send OTP
      add(ResetPasswordRemainingSecondsForReSendOtpChanged(seconds: remainingSecondsForReSendOtp));

      if (remainingSecondsForReSendOtp == 0) {
        timer.cancel();
      }
    });
  }

  void _onEmailInputChanged(
    ResetPasswordEmailInputChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    if (event.email.isEmpty) {
      emit(state.copyWith(emailError: S.current.emailRequired));
    } else {
      emit(state.copyWith(emailError: ''));
    }

    emit(
      state.copyWith(
        email: event.email,
        isEnableConfirmEmailButton: _confirmEmailButtonEnable(
          email: event.email,
          counter: state.remainingSecondsForReSendOtp,
        ),
      ),
    );
  }

  Future<void> _onConfirmEmailButtonPressed(
    ResetPasswordConfirmEmailButtonPressed event,
    Emitter<ResetPasswordState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        // Validate email format
        if (!RegexConstants.email.hasMatch(state.email)) {
          emit(state.copyWith(emailError: S.current.invalidEmailFormat));

          return;
        }

        await _sendOtpForResetPasswordUseCase.execute(
          SendOtpForResetPasswordInput(email: state.email),
        );

        // Start timer for re-send OTP
        _startTimerForReSendOtp();

        emit(state.copyWith(resetPasswordStep: ResetPasswordStep.otpConfirm));
      },
    );
  }

  void _onResetPasswordBackToPreviousStepButtonPressed(
    ResetPasswordBackToPreviousStepButtonPressed event,
    Emitter<ResetPasswordState> emit,
  ) {
    // Clear all data and go back to the first step
    emit(
      state.copyWith(
        resetPasswordStep: ResetPasswordStep.emailConfirm,
        email: '',
        password: '',
        confirmPassword: '',
        otp: '',
        isEnableConfirmEmailButton: false,
        isEnableConfirmOtpButton: false,
        isEnableResetPasswordButton: false,
      ),
    );
  }

  void _onResetPasswordOtpInputChanged(
    ResetPasswordOtpInputChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(
      state.copyWith(otp: event.otp, isEnableConfirmOtpButton: _confirmOtpButtonEnable(event.otp)),
    );
  }

  Future<void> _onConfirmOtpResetPasswordButtonPressed(
    ResetPasswordConfirmOtpButtonPressed event,
    Emitter<ResetPasswordState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _verifyOtpForResetPasswordUseCase.execute(
          VerifyOtpForResetPasswordInput(email: state.email, code: state.otp),
        );

        emit(state.copyWith(resetPasswordStep: ResetPasswordStep.resettingPassword));
      },
    );
  }

  void _onResetPasswordRemainingSecondsForReSendOtpChanged(
    ResetPasswordRemainingSecondsForReSendOtpChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        remainingSecondsForReSendOtp: event.seconds,
        isEnableConfirmEmailButton: _confirmEmailButtonEnable(
          email: state.email,
          counter: event.seconds,
        ),
      ),
    );
  }

  Future<void> _onResetPasswordResendOtpButtonPressed(
    ResetPasswordResendOtpButtonPressed event,
    Emitter<ResetPasswordState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _sendOtpForResetPasswordUseCase.execute(
          SendOtpForResetPasswordInput(email: state.email),
        );

        // Restart timer for re-send OTP
        _startTimerForReSendOtp();
      },
    );
  }

  void _onResetPasswordPasswordInputChanged(
    ResetPasswordPasswordInputChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    if (event.password.isEmpty) {
      emit(state.copyWith(passwordError: S.current.passwordRequired));
    } else {
      emit(state.copyWith(passwordError: ''));
    }

    emit(
      state.copyWith(
        password: event.password,
        isEnableResetPasswordButton: _resetPasswordConfirmButtonEnable(
          email: state.email,
          password: event.password,
          confirmPassword: state.confirmPassword,
        ),
      ),
    );
  }

  void _onResetPasswordConfirmPasswordInputChanged(
    ResetPasswordConfirmPasswordInputChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    if (event.confirmPassword != state.password) {
      emit(state.copyWith(confirmPasswordError: S.current.confirmPasswordDoesNotMatch));
    } else {
      emit(state.copyWith(confirmPasswordError: ''));
    }

    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        isEnableResetPasswordButton: _resetPasswordConfirmButtonEnable(
          email: state.email,
          password: state.password,
          confirmPassword: event.confirmPassword,
        ),
      ),
    );
  }

  Future<void> _onResetPasswordConfirmButtonPressed(
    ResetPasswordButtonPressed event,
    Emitter<ResetPasswordState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        await _resetUserPasswordUseCase.execute(
          ResetUserPasswordInput(email: state.email, password: state.password),
        );

        emit(state.copyWith(resetPasswordStep: ResetPasswordStep.resetPasswordComplete));
      },
    );
  }
}
