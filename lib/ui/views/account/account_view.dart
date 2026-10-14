import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends BasePageState<AccountView, AccountBloc> {
  @override
  bool get useSkeletonLoading => true;

  @override
  void initState() {
    bloc.add(const AccountViewInitiated());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.account),
      body: NoirScaffoldBody(
        child: buildSkeletonOrContent(
          skeleton: const AccountLoadingSkeletonWidget(),
          content: Padding(
            padding: EdgeInsets.only(top: Dimens.d30.responsive()),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: Dimens.d40.responsive()),
                        const _AccountInfoWidget(),
                        SizedBox(height: Dimens.d20.responsive()),
                        const _UtilitiesWidget(),
                        SizedBox(height: Dimens.d20.responsive()),
                        BlocBuilder<AccountBloc, AccountState>(
                          buildWhen: (previous, current) =>
                              previous.biometricLoginStatus != current.biometricLoginStatus ||
                              previous.isBiometricLoginUpdating != current.isBiometricLoginUpdating,
                          builder: (context, state) {
                            return AccountBiometricLoginWidget(
                              status: state.biometricLoginStatus,
                              isUpdating: state.isBiometricLoginUpdating,
                              onChanged: (enabled) => _onBiometricLoginChanged(enabled),
                            );
                          },
                        ),
                        SizedBox(height: Dimens.d20.responsive()),
                        CommonButton(
                          text: S.current.signOut,
                          backgroundColor: surfaceColor,
                          textColor: redColor,
                          onTap: () {
                            navigator.showDialog(
                              AppPopupInfo.confirm(
                                message: S.current.areYouSureYouWantToSignOut,
                                showCancel: true,
                                onPressed: Func0(() {
                                  appBloc.add(const SignOutButtonPressed());
                                }),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const _UserCircleAvatarWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onBiometricLoginChanged(bool enabled) async {
    if (!enabled) {
      bloc.add(const AccountBiometricLoginToggled(enabled: false));
      return;
    }

    final password = await _requestBiometricPassword();
    if (password == null || password.isEmpty) return;
    bloc.add(AccountBiometricLoginToggled(enabled: true, password: password));
  }

  Future<String?> _requestBiometricPassword() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimens.d20.responsive()),
              side: BorderSide(color: glassHairlineColor),
            ),
            child: Padding(
              padding: EdgeInsets.all(Dimens.d20.responsive()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.current.biometricSignIn, style: AppTextStyles.s18wBoldBlack()),
                  SizedBox(height: Dimens.d8.responsive()),
                  Text(S.current.biometricEnableExplanation, style: AppTextStyles.s14wNormalGrey()),
                  SizedBox(height: Dimens.d16.responsive()),
                  CommonTextField(
                    controller: controller,
                    hintText: S.current.hintPassword,
                    isPasswordField: true,
                  ),
                  SizedBox(height: Dimens.d16.responsive()),
                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          text: S.current.cancel,
                          backgroundColor: frameColor,
                          onTap: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                      SizedBox(width: Dimens.d8.responsive()),
                      Expanded(
                        child: CommonButton(
                          text: S.current.confirm,
                          onTap: () => Navigator.of(dialogContext).pop(controller.text),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }
}

class _UserCircleAvatarWidget extends StatelessWidget {
  const _UserCircleAvatarWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen: (previous, current) => previous.user.avatarUrl != current.user.avatarUrl,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: CommonCircleNetworkImage(
            imageUrl: state.user.avatarUrl,
            enablePadding: false,
            size: Dimens.d80.responsive(),
            placeHolderType: ImagePlaceHolderType.user,
          ),
        );
      },
    );
  }
}

class _AccountInfoWidget extends StatelessWidget {
  const _AccountInfoWidget();

  @override
  Widget build(BuildContext context) {
    return CommonGlassPanel(
      child: Column(
        children: [
          SizedBox(height: Dimens.d40.responsive()),
          BlocBuilder<AccountBloc, AccountState>(
            buildWhen: (previous, current) => previous.user.fullName != current.user.fullName,
            builder: (context, state) {
              return Text(state.user.fullName, style: AppTextStyles.s18wBoldBlack());
            },
          ),
          BlocBuilder<AccountBloc, AccountState>(
            buildWhen: (previous, current) => previous.user.email != current.user.email,
            builder: (context, state) {
              return Text(state.user.email, style: AppTextStyles.s14wNormalBlack());
            },
          ),
          CommonLine(
            margin: EdgeInsets.only(
              top: Dimens.d10.responsive(),
              left: Dimens.d16.responsive(),
              right: Dimens.d16.responsive(),
            ),
          ),
          CommonForwardButton(
            title: S.current.changePassword,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Assets.icons.locker.svg(
              width: Dimens.d24.responsive(),
              height: Dimens.d24.responsive(),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Dimens.d16.responsive()),
              bottomRight: Radius.circular(Dimens.d16.responsive()),
            ),
            onTap: () {
              context.read<AppNavigator>().push(const AppRouteInfo.resetPassword());
            },
          ),
        ],
      ),
    );
  }
}

class _UtilitiesWidget extends StatelessWidget {
  const _UtilitiesWidget();

  @override
  Widget build(BuildContext context) {
    return CommonGlassPanel(
      child: Column(
        children: [
          CommonForwardButton(
            title: S.current.myWallets,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Assets.icons.walletImagePlaceHolder.svg(
              width: Dimens.d24.responsive(),
              height: Dimens.d24.responsive(),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.d16.responsive()),
              topRight: Radius.circular(Dimens.d16.responsive()),
            ),
            onTap: () {
              context.read<AppNavigator>().push(const AppRouteInfo.wallets());
            },
          ),
          CommonLine(margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive())),
          CommonForwardButton(
            title: S.current.categories,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Assets.icons.categoryImagePlaceHolder.svg(
              width: Dimens.d24.responsive(),
              height: Dimens.d24.responsive(),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Dimens.d16.responsive()),
              bottomRight: Radius.circular(Dimens.d16.responsive()),
            ),
            onTap: () {
              context.read<AppNavigator>().push(const AppRouteInfo.categories());
            },
          ),
          CommonLine(margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive())),
          const AccountThemeSelectorWidget(),
        ],
      ),
    );
  }
}
