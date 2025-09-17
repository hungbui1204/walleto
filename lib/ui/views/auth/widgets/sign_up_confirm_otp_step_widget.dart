import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SignUpConfirmOtpStepWidget extends StatelessWidget {
  const SignUpConfirmOtpStepWidget({super.key, required this.otpSignUpController});

  final TextEditingController otpSignUpController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) => previous.signUpEmail != current.signUpEmail,
            builder: (context, state) {
              return Text.rich(
                TextSpan(
                  text: S.current.aSixDigitCodeHasBeenSentToEmail,
                  style: AppTextStyles.s14wNormalBlack(),
                  children: [
                    TextSpan(text: state.signUpEmail, style: AppTextStyles.s14wBoldBlack()),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: Dimens.d20.responsive()),
          _OtpForm(otpSignUpController: otpSignUpController),
          SizedBox(height: Dimens.d20.responsive()),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.isEnableConfirmOtpSignUpButton !=
                      current.isEnableConfirmOtpSignUpButton ||
                  previous.remainingSecondsForReSendOtp != current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return CommonButton(
                text: S.current.confirm,
                onTap:
                    state.isEnableConfirmOtpSignUpButton
                        ? () {
                          ViewUtils.hideKeyboard(context);
                          context.read<LoginBloc>().add(const ConfirmOtpSignUpButtonPressed());
                        }
                        : null,
              );
            },
          ),
          SizedBox(height: Dimens.d10.responsive()),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.remainingSecondsForReSendOtp != current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return ButtonWithSecondCounting(
                text: S.current.resendCode,
                count: state.remainingSecondsForReSendOtp,
                color: secondaryColor,
                onTap: () {
                  context.read<LoginBloc>().add(const SignUpResendOtpButtonPressed());
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OtpForm extends StatelessWidget {
  const _OtpForm({required this.otpSignUpController});

  final TextEditingController otpSignUpController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.otp != current.otp || previous.otpError != current.otpError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  prefixIcon: Assets.icons.locker.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  prefixBackgroundColor: secondaryShadeColor,
                  hintText: S.current.hintOtp,
                  controller: otpSignUpController,
                  onChanged: (otp) {
                    context.read<LoginBloc>().add(SignUpOtpInputChanged(otp: otp));
                  },
                ),
                if (state.otpError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.otpError, style: AppTextStyles.s14wNormalRed()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
