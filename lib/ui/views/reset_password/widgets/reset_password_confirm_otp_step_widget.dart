import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ResetPasswordConfirmOtpStepWidget extends StatelessWidget {
  const ResetPasswordConfirmOtpStepWidget({
    super.key,
    required this.otpController,
  });

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            buildWhen: (previous, current) => previous.email != current.email,
            builder: (context, state) {
              return Text.rich(
                TextSpan(
                  text: S.current.aSixDigitCodeHasBeenSentToEmail,
                  style: AppTextStyles.s14wNormalBlack(),
                  children: [
                    TextSpan(
                      text: state.email,
                      style: AppTextStyles.s14wBoldBlack(),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: Dimens.d20.responsive()),
          _OtpForm(otpController: otpController),
          SizedBox(height: Dimens.d20.responsive()),
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            buildWhen: (previous, current) {
              return previous.isEnableConfirmOtpButton !=
                      current.isEnableConfirmOtpButton ||
                  previous.remainingSecondsForReSendOtp !=
                      current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return CommonButton(
                text: S.current.confirm,
                onTap:
                    state.isEnableConfirmOtpButton
                        ? () {
                          ViewUtils.hideKeyboard(context);
                          context.read<ResetPasswordBloc>().add(
                            const ResetPasswordConfirmOtpButtonPressed(),
                          );
                        }
                        : null,
              );
            },
          ),
          SizedBox(height: Dimens.d10.responsive()),
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            buildWhen: (previous, current) {
              return previous.remainingSecondsForReSendOtp !=
                  current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return ButtonWithSecondCounting(
                text: S.current.resendCode,
                count: state.remainingSecondsForReSendOtp,
                color: primaryShadeColor,
                onTap: () {
                  context.read<ResetPasswordBloc>().add(
                    const ResetPasswordResendOtpButtonPressed(),
                  );
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
  const _OtpForm({required this.otpController});

  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          buildWhen: (previous, current) {
            return previous.otp != current.otp ||
                previous.otpError != current.otpError;
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
                  controller: otpController,
                  onChanged: (otp) {
                    context.read<ResetPasswordBloc>().add(
                      ResetPasswordOtpInputChanged(otp: otp),
                    );
                  },
                ),
                if (state.otpError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(
                      state.otpError,
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
