import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState
    extends BasePageState<ResetPasswordView, ResetPasswordBloc> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController otpController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    otpController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.resetPassword),
      body: NoirScaffoldBody(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                  buildWhen:
                      (previous, current) =>
                          previous.resetPasswordStep !=
                          current.resetPasswordStep,
                  builder: (context, state) {
                    if (state.resetPasswordStep ==
                            ResetPasswordStep.emailConfirm ||
                        state.resetPasswordStep ==
                            ResetPasswordStep.resetPasswordComplete) {
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
                              emailController.clear();
                              passwordController.clear();
                              otpController.clear();
                              confirmPasswordController.clear();

                              // Go back to the first step
                              context.read<ResetPasswordBloc>().add(
                                const ResetPasswordBackToPreviousStepButtonPressed(),
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
                BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                  buildWhen: (previous, current) {
                    return previous.resetPasswordStep !=
                        current.resetPasswordStep;
                  },
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
                        key: ValueKey(state.resetPasswordStep),
                        child: switch (state.resetPasswordStep) {
                          ResetPasswordStep.emailConfirm =>
                            ResetPasswordConfirmEmailStepWidget(
                              emailController: emailController,
                            ),
                          ResetPasswordStep.otpConfirm =>
                            ResetPasswordConfirmOtpStepWidget(
                              otpController: otpController,
                            ),
                          ResetPasswordStep.resettingPassword =>
                            ResetPasswordResettingPasswordStepWidget(
                              passwordController: passwordController,
                              confirmPasswordController:
                                  confirmPasswordController,
                            ),
                          ResetPasswordStep.resetPasswordComplete =>
                            const ResetPasswordCompleteStepWidget(),
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
