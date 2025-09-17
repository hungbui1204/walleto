import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SignUpSigningUpStepWidget extends StatelessWidget {
  const SignUpSigningUpStepWidget({
    super.key,
    required this.passwordSignUpController,
    required this.confirmPasswordSignUpController,
  });

  final TextEditingController passwordSignUpController;
  final TextEditingController confirmPasswordSignUpController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _EmailWidget(),
          SizedBox(height: Dimens.d16.responsive()),
          _PasswordForm(signUpPasswordController: passwordSignUpController),
          SizedBox(height: Dimens.d16.responsive()),
          _PasswordConfirmForm(signUpConfirmPasswordController: confirmPasswordSignUpController),
          SizedBox(height: Dimens.d16.responsive()),
          const _AcceptTermCheckbox(),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.isEnableSignUpButton != current.isEnableSignUpButton;
            },
            builder: (context, state) {
              return CommonButton(
                text: S.current.signUp,
                onTap:
                    state.isEnableSignUpButton
                        ? () {
                          context.read<LoginBloc>().add(const SignUpConfirmButtonPressed());
                        }
                        : null,
              );
            },
          ),
          SizedBox(height: Dimens.d20.responsive()),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                // TODO: Open Terms and Conditions
              },
              child: Text(
                S.current.termsAndConditions,
                style: AppTextStyles.s12wNormalBlack().copyWith(
                  decoration: TextDecoration.underline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
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
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) => previous.signUpEmail != current.signUpEmail,
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
                  Text(state.signUpEmail, style: AppTextStyles.s14wBoldBlack()),
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
  const _PasswordForm({required this.signUpPasswordController});

  final TextEditingController signUpPasswordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.password, style: AppTextStyles.s14wBoldBlack()),
        SizedBox(height: Dimens.d4.responsive()),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.signUpPassword != current.signUpPassword ||
                previous.signUpPasswordError != current.signUpPasswordError;
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
                    context.read<LoginBloc>().add(SignUpPasswordInputChanged(password: password));
                  },
                  controller: signUpPasswordController,
                  isPasswordField: true,
                ),
                if (state.signUpPasswordError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.signUpPasswordError, style: AppTextStyles.s14wNormalRed()),
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
  const _PasswordConfirmForm({required this.signUpConfirmPasswordController});

  final TextEditingController signUpConfirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(S.current.confirmPassword, style: AppTextStyles.s14wBoldBlack()),
        SizedBox(height: Dimens.d4.responsive()),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.signUpConfirmPassword != current.signUpConfirmPassword ||
                previous.signUpConfirmPasswordError != current.signUpConfirmPasswordError;
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
                  hintText: S.current.hintConfirmPassword,
                  onChanged: (password) {
                    context.read<LoginBloc>().add(
                      SignUpConfirmPasswordInputChanged(confirmPassword: password),
                    );
                  },
                  controller: signUpConfirmPasswordController,
                  isPasswordField: true,
                ),
                if (state.signUpConfirmPasswordError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(
                      state.signUpConfirmPasswordError,
                      style: AppTextStyles.s14wNormalRed(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AcceptTermCheckbox extends StatelessWidget {
  const _AcceptTermCheckbox();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        context.read<LoginBloc>().add(const SignUpAcceptTermsCheckboxToggled());
      },
      child: Row(
        children: [
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.isCheckedAcceptTerms != current.isCheckedAcceptTerms;
            },
            builder: (context, state) {
              return Checkbox(
                visualDensity: VisualDensity.comfortable,
                fillColor:
                    state.isCheckedAcceptTerms
                        ? WidgetStateProperty.all(primaryColor)
                        : WidgetStateProperty.all(greyColor),
                side: BorderSide.none,
                value: state.isCheckedAcceptTerms,
                onChanged: (_) {
                  context.read<LoginBloc>().add(const SignUpAcceptTermsCheckboxToggled());
                },
              );
            },
          ),
          Text(S.current.acceptOurTerms, style: AppTextStyles.s12wNormalBlack()),
        ],
      ),
    );
  }
}
