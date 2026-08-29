import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SignUpTab extends StatelessWidget {
  const SignUpTab({
    super.key,
    required this.emailSignUpController,
    required this.passwordSignUpController,
    required this.otpSignUpController,
    required this.confirmPasswordSignUpController,
    required this.tabController,
  });

  final TextEditingController emailSignUpController;
  final TextEditingController passwordSignUpController;
  final TextEditingController otpSignUpController;
  final TextEditingController confirmPasswordSignUpController;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen:
                  (previous, current) =>
                      previous.signUpStep != current.signUpStep,
              builder: (context, state) {
                if (state.signUpStep == SignUpStep.emailConfirm ||
                    state.signUpStep == SignUpStep.signUpComplete) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    SizedBox(height: Dimens.d10.responsive()),
                    Material(
                      color: transParentColor,
                      child: InkWell(
                        borderRadius: BorderRadius.all(
                          Radius.circular(Dimens.d8.responsive()),
                        ),
                        onTap: () {
                          // Clear all inputs
                          emailSignUpController.clear();
                          passwordSignUpController.clear();
                          otpSignUpController.clear();
                          confirmPasswordSignUpController.clear();

                          // Go back to the first step
                          context.read<LoginBloc>().add(
                            const SignUpBackToPreviousStepButtonPressed(),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(
                            Dimens.d8.responsive(),
                          ).copyWith(left: 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_sharp,
                                size: Dimens.d14.responsive(),
                              ),
                              SizedBox(width: Dimens.d8.responsive()),
                              Text(
                                S.current.backToFirstStep,
                                style: AppTextStyles.s16wNormalBlack(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: Dimens.d10.responsive()),
            BlocBuilder<LoginBloc, LoginState>(
              buildWhen:
                  (previous, current) =>
                      previous.signUpStep != current.signUpStep,
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: DurationConstants.defaultAnimationDuration,
                  transitionBuilder: (child, animation) {
                    const begin = Offset(1.0, 0.0); // Slide from right
                    const end = Offset.zero;
                    final tween = Tween<Offset>(begin: begin, end: end);
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(state.signUpStep),
                    child: switch (state.signUpStep) {
                      SignUpStep.emailConfirm => SignUpConfirmEmailStepWidget(
                        emailSignUpController: emailSignUpController,
                      ),
                      SignUpStep.otpConfirm => SignUpConfirmOtpStepWidget(
                        otpSignUpController: otpSignUpController,
                      ),
                      SignUpStep.signingUp => SignUpSigningUpStepWidget(
                        passwordSignUpController: passwordSignUpController,
                        confirmPasswordSignUpController:
                            confirmPasswordSignUpController,
                      ),
                      SignUpStep.signUpComplete => SignUpCompleteStepWidget(
                        tabController: tabController,
                      ),
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
