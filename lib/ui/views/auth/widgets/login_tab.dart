import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class LoginTab extends StatelessWidget {
  const LoginTab({super.key, required this.emailController, required this.passwordController});

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: Column(
          children: [
            SizedBox(height: Dimens.d30.responsive()),
            _EmailForm(emailController: emailController),
            SizedBox(height: Dimens.d20.responsive()),
            _PasswordForm(passwordController: passwordController),
            SizedBox(height: Dimens.d30.responsive()),
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (previous, current) {
                return previous.isEnableLoginButton != current.isEnableLoginButton;
              },
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    text: S.current.login,
                    onTap: state.isEnableLoginButton
                        ? () {
                            ViewUtils.hideKeyboard(context);
                            context.read<LoginBloc>().add(const SignInButtonPressed());
                          }
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: Dimens.d20.responsive()),
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (previous, current) =>
                  previous.isBiometricLoginEnabled != current.isBiometricLoginEnabled ||
                  previous.isBiometricLoginAvailable != current.isBiometricLoginAvailable ||
                  previous.isBiometricLoginLoading != current.isBiometricLoginLoading,
              builder: (context, state) {
                if (!state.isBiometricLoginAvailable || !state.isBiometricLoginEnabled) {
                  return const SizedBox.shrink();
                }
                return LoginBiometricButtonWidget(
                  isLoading: state.isBiometricLoginLoading,
                  onTap: () => context.read<LoginBloc>().add(const BiometricLoginButtonPressed()),
                );
              },
            ),
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (previous, current) =>
                  previous.hasStoredSession != current.hasStoredSession ||
                  previous.isSessionRetryLoading != current.isSessionRetryLoading,
              builder: (context, state) {
                if (!state.hasStoredSession) return const SizedBox.shrink();
                return SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    text: S.current.retry,
                    backgroundColor: surfaceColor,
                    textColor: primaryColor,
                    icon: state.isSessionRetryLoading
                        ? SizedBox(
                            width: Dimens.d18.responsive(),
                            height: Dimens.d18.responsive(),
                            child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                          )
                        : null,
                    onTap: state.isSessionRetryLoading
                        ? null
                        : () => context.read<LoginBloc>().add(const SessionRetryButtonPressed()),
                  ),
                );
              },
            ),
            SizedBox(height: Dimens.d20.responsive()),
            Row(
              children: [
                Pressable(
                  onTap: () {
                    context.read<AppNavigator>().push(const AppRouteInfo.resetPassword());
                  },
                  child: Text(
                    S.current.forgetPassword,
                    style: AppTextStyles.s14wNormalUnderlinePrimary(),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimens.d30.responsive()),
          ],
        ),
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.email != current.email || previous.emailError != current.emailError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  prefixIcon: Assets.icons.accountActive.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  hintText: S.current.hintEmail,
                  controller: emailController,
                  onChanged: (email) {
                    context.read<LoginBloc>().add(LoginEmailInputChanged(email: email));
                  },
                ),
                if (state.emailError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.emailError, style: AppTextStyles.s14wNormalRed()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({required this.passwordController});

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.password != current.password ||
                previous.passwordError != current.passwordError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  prefixIcon: Assets.icons.locker.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  hintText: S.current.hintPassword,
                  onChanged: (password) {
                    context.read<LoginBloc>().add(LoginPasswordInputChanged(password: password));
                  },
                  controller: passwordController,
                  isPasswordField: true,
                ),
                if (state.passwordError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.passwordError, style: AppTextStyles.s14wNormalRed()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
