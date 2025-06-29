import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEmailInputChanged>(_onEmailInputChanged, transformer: log());
    on<LoginPasswordInputChanged>(_onPasswordInputChanged, transformer: log());
    on<SignInButtonPressed>(_onSignIn, transformer: log());
  }

  bool _loginButtonEnable({required String email, required String password}) {
    return email.isNotEmpty && password.isNotEmpty;
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

  Future<void> _onSignIn(SignInButtonPressed event, Emitter<LoginState> emit) async {
    await runBlocCatching(
      action: () async {
        // TODO: Implement login logic
      },
    );
  }
}
