import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class LoginBiometricButtonWidget extends StatelessWidget {
  const LoginBiometricButtonWidget({super.key, required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: frameColor)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d10.responsive()),
              child: Text(S.current.orSignInFaster, style: AppTextStyles.s14wNormalGrey()),
            ),
            Expanded(child: Divider(color: frameColor)),
          ],
        ),
        SizedBox(height: Dimens.d12.responsive()),
        CommonButton(
          text: isLoading ? S.current.biometricSigningIn : S.current.continueWithBiometrics,
          icon: isLoading
              ? SizedBox(
                  width: Dimens.d18.responsive(),
                  height: Dimens.d18.responsive(),
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : Icon(Icons.fingerprint, color: secondaryColor),
          backgroundColor: primaryShadeColor,
          textColor: secondaryColor,
          onTap: isLoading ? null : onTap,
        ),
        SizedBox(height: Dimens.d8.responsive()),
        Text(
          S.current.biometricLoginForThisDevice,
          style: AppTextStyles.s14wNormalGrey(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
