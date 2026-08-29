import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SignUpCompleteStepWidget extends StatelessWidget {
  const SignUpCompleteStepWidget({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimens.d20.responsive()),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(Dimens.d16.responsive()),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
          child: Icon(
            Icons.check,
            color: onPrimaryColor,
            size: Dimens.d48.responsive(),
          ),
        ),
        SizedBox(height: Dimens.d24.responsive()),
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen:
              (previous, current) =>
                  previous.signUpEmail != current.signUpEmail,
          builder: (context, state) {
            return Text(
              S.current.newAccountWithEmailIsCreatedSuccessfully(
                state.signUpEmail,
              ),
              style: AppTextStyles.s15wNormalBlack(),
            );
          },
        ),
        SizedBox(height: Dimens.d24.responsive()),
        InkWell(
          onTap: () {
            // Navigate to the login tab
            tabController.animateTo(0);
          },
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: Dimens.d56.responsive(),
                color: primaryColor,
              ),
              SizedBox(width: Dimens.d8.responsive()),
              Text(S.current.loginNow, style: AppTextStyles.s16wBoldBlack()),
            ],
          ),
        ),
      ],
    );
  }
}
