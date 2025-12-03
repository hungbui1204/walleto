import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';

class ResetPasswordCompleteStepWidget extends StatelessWidget {
  const ResetPasswordCompleteStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Dimens.d20.responsive()),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(Dimens.d16.responsive()),
          decoration: const BoxDecoration(shape: BoxShape.circle, color: primaryColor),
          child: Icon(Icons.check, color: whiteColor, size: Dimens.d48.responsive()),
        ),
        SizedBox(height: Dimens.d24.responsive()),
        Center(
          child: Text(S.current.passwordResetSuccessfully, style: AppTextStyles.s15wNormalBlack()),
        ),
        SizedBox(height: Dimens.d24.responsive()),
        InkWell(
          onTap: () => getIt.get<AppNavigator>().pop(),
          child: Row(
            children: [
              Icon(Icons.arrow_back_rounded, size: Dimens.d56.responsive(), color: primaryColor),
              SizedBox(width: Dimens.d8.responsive()),
              Text(S.current.loginNow, style: AppTextStyles.s16wBoldBlack()),
            ],
          ),
        ),
      ],
    );
  }
}
