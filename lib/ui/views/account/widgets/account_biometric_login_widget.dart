import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class AccountBiometricLoginWidget extends StatelessWidget {
  const AccountBiometricLoginWidget({
    super.key,
    required this.status,
    required this.isUpdating,
    required this.onChanged,
  });

  final BiometricLoginStatus status;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = status.isEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Dimens.d8.responsive(), bottom: Dimens.d8.responsive()),
          child: Text(S.current.security, style: AppTextStyles.s14wBoldGrey()),
        ),
        CommonGlassPanel(
          child: Padding(
            padding: EdgeInsets.all(Dimens.d16.responsive()),
            child: Row(
              children: [
                Container(
                  width: Dimens.d44.responsive(),
                  height: Dimens.d44.responsive(),
                  decoration: BoxDecoration(
                    color: primaryShadeColor,
                    borderRadius: BorderRadius.circular(Dimens.d14.responsive()),
                  ),
                  child: Icon(Icons.fingerprint, color: primaryColor),
                ),
                SizedBox(width: Dimens.d12.responsive()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.current.biometricSignIn, style: AppTextStyles.s16wBoldBlack()),
                      SizedBox(height: Dimens.d4.responsive()),
                      Text(
                        status.isAvailable
                            ? S.current.biometricSignInDescription
                            : S.current.biometricSetupDeviceSettings,
                        style: AppTextStyles.s14wNormalGrey(),
                      ),
                      if (enabled) ...[
                        SizedBox(height: Dimens.d8.responsive()),
                        Text(
                          S.current.biometricSignInEnabledMessage,
                          style: AppTextStyles.s14wNormalGreen(),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: Dimens.d12.responsive()),
                if (isUpdating)
                  SizedBox(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                else
                  _BiometricSwitch(
                    enabled: enabled,
                    available: status.isAvailable,
                    onChanged: onChanged,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BiometricSwitch extends StatelessWidget {
  const _BiometricSwitch({required this.enabled, required this.available, required this.onChanged});

  final bool enabled;
  final bool available;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: enabled,
      enabled: available,
      label: S.current.biometricSignIn,
      child: Pressable(
        semanticLabel: S.current.biometricSignIn,
        onTap: available ? () => onChanged(!enabled) : null,
        feedback: PressableFeedback.none,
        child: AnimatedContainer(
          duration: DurationConstants.microInteraction,
          width: Dimens.d48.responsive(),
          height: Dimens.d28.responsive(),
          padding: EdgeInsets.all(Dimens.d4.responsive()),
          decoration: BoxDecoration(
            color: enabled ? primaryColor : frameColor,
            borderRadius: BorderRadius.circular(Dimens.d20.responsive()),
          ),
          child: Align(
            alignment: enabled ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: Dimens.d20.responsive(),
              height: Dimens.d20.responsive(),
              decoration: BoxDecoration(
                color: enabled ? onPrimaryColor : whiteColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
