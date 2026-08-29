import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ResetPasswordConfirmEmailStepWidget extends StatelessWidget {
  const ResetPasswordConfirmEmailStepWidget({super.key, required this.emailController});

  final TextEditingController emailController;

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
          _EmailForm(emailController: emailController),
          SizedBox(height: Dimens.d20.responsive()),
          BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
            buildWhen: (previous, current) {
              return previous.isEnableConfirmEmailButton != current.isEnableConfirmEmailButton ||
                  previous.remainingSecondsForReSendOtp != current.remainingSecondsForReSendOtp;
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: ButtonWithSecondCounting(
                  count: state.remainingSecondsForReSendOtp,
                  text: S.current.sendCode,
                  onTap:
                      state.isEnableConfirmEmailButton
                          ? () {
                            ViewUtils.hideKeyboard(context);
                            context.read<ResetPasswordBloc>().add(
                              const ResetPasswordConfirmEmailButtonPressed(),
                            );
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
  const _EmailForm({required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
          buildWhen: (previous, current) {
            return previous.email != current.email || previous.emailError != current.emailError;
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
                  controller: emailController,
                  onChanged: (email) {
                    context.read<ResetPasswordBloc>().add(
                      ResetPasswordEmailInputChanged(email: email),
                    );
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
