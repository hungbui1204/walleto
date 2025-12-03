import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ResetPasswordResettingPasswordStepWidget extends StatelessWidget {
  const ResetPasswordResettingPasswordStepWidget({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _EmailWidget(),
          SizedBox(height: Dimens.d16.responsive()),
          _PasswordForm(passwordController: passwordController),
          SizedBox(height: Dimens.d16.responsive()),
          _PasswordConfirmForm(confirmPasswordController: confirmPasswordController),
          SizedBox(height: Dimens.d36.responsive()),
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            buildWhen: (previous, current) {
              return previous.isEnableResetPasswordButton != current.isEnableResetPasswordButton;
            },
            builder: (context, state) {
              return CommonButton(
                text: S.current.resetPassword,
                onTap:
                    state.isEnableResetPasswordButton
                        ? () {
                          context.read<ResetPasswordBloc>().add(const ResetPasswordButtonPressed());
                        }
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmailWidget extends StatelessWidget {
  const _EmailWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.yourConfirmedEmail, style: AppTextStyles.s14wBoldBlack()),
        SizedBox(height: Dimens.d4.responsive()),
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          buildWhen: (previous, current) => previous.email != current.email,
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                color: whiteColor,
                border: Border.all(),
                borderRadius: BorderRadius.all(Radius.circular(Dimens.d12.responsive())),
              ),
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: Dimens.d8.responsive()),
                    padding: EdgeInsets.all(Dimens.d16.responsive()),
                    decoration: BoxDecoration(
                      color: primaryShadeColor,
                      border: const Border(right: BorderSide()),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimens.d12.responsive()),
                        bottomLeft: Radius.circular(Dimens.d12.responsive()),
                      ),
                    ),
                    child: Assets.icons.accountActive.svg(
                      width: Dimens.d24.responsive(),
                      height: Dimens.d24.responsive(),
                    ),
                  ),
                  Text(state.email, style: AppTextStyles.s14wBoldBlack()),
                ],
              ),
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
        Text(S.current.newPassword, style: AppTextStyles.s14wBoldBlack()),
        SizedBox(height: Dimens.d4.responsive()),
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
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
                  hintText: S.current.hintNewPassword,
                  onChanged: (password) {
                    context.read<ResetPasswordBloc>().add(
                      ResetPasswordPasswordInputChanged(password: password),
                    );
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

class _PasswordConfirmForm extends StatelessWidget {
  const _PasswordConfirmForm({required this.confirmPasswordController});

  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.confirmNewPassword, style: AppTextStyles.s14wBoldBlack()),
        SizedBox(height: Dimens.d4.responsive()),
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          buildWhen: (previous, current) {
            return previous.confirmPassword != current.confirmPassword ||
                previous.confirmPasswordError != current.confirmPasswordError;
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
                  hintText: S.current.hintConfirmNewPassword,
                  onChanged: (password) {
                    context.read<ResetPasswordBloc>().add(
                      ResetPasswordConfirmPasswordInputChanged(confirmPassword: password),
                    );
                  },
                  controller: confirmPasswordController,
                  isPasswordField: true,
                ),
                if (state.confirmPasswordError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.confirmPasswordError, style: AppTextStyles.s14wNormalRed()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
