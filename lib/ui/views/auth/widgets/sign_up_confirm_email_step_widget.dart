import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SignUpConfirmEmailStepWidget extends StatelessWidget {
  const SignUpConfirmEmailStepWidget({super.key, required this.emailSignUpController});

  final TextEditingController emailSignUpController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            S.current.weWillSendYouAnEmailWithOTPCodeToConfirmEmail,
            style: AppTextStyles.s14wNormalBlack(),
          ),
          SizedBox(height: Dimens.d10.responsive()),
          _EmailForm(emailSignUpController: emailSignUpController),
          SizedBox(height: Dimens.d20.responsive()),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.isEnableConfirmEmailSignUpButton !=
                      current.isEnableConfirmEmailSignUpButton ||
                  previous.remainingSecondsForReSendOtp != current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ButtonWithSecondCounting(
                  count: state.remainingSecondsForReSendOtp,
                  text: S.current.sendCode,
                  onTap:
                      state.isEnableConfirmEmailSignUpButton
                          ? () {
                            ViewUtils.hideKeyboard(context);
                            context.read<LoginBloc>().add(const ConfirmEmailSignUpButtonPressed());
                          }
                          : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({required this.emailSignUpController});

  final TextEditingController emailSignUpController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.signUpEmail != current.signUpEmail ||
                previous.signUpEmailError != current.signUpEmailError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  prefixIcon: Assets.icons.email.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  hintText: S.current.hintEmail,
                  controller: emailSignUpController,
                  onChanged: (email) {
                    context.read<LoginBloc>().add(SignUpEmailInputChanged(email: email));
                  },
                ),
                if (state.signUpEmailError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.signUpEmailError, style: AppTextStyles.s14wNormalRed()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
