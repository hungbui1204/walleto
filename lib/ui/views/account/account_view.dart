import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
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
  void initState() {
    bloc.add(const AccountViewInitiated());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.account),
      body: NoirScaffoldBody(
        child: Padding(
          padding: EdgeInsets.only(top: Dimens.d30.responsive()),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.d16.responsive(),
                ),
                child: Column(
                  children: [
                    SizedBox(height: Dimens.d40.responsive()),
                    const _AccountInfoWidget(),
                    SizedBox(height: Dimens.d20.responsive()),
                    const _UtilitiesWidget(),
                    SizedBox(height: Dimens.d20.responsive()),
                    const _SupportiveWidget(),
                    SizedBox(height: Dimens.d20.responsive()),
                    CommonButton(
                      text: S.current.signOut,
                      backgroundColor: surfaceColor,
                      textColor: redColor,
                      onTap: () {
                        getIt.get<AppNavigator>().showDialog(
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
              const _UserCircleAvatarWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserCircleAvatarWidget extends StatelessWidget {
  const _UserCircleAvatarWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      buildWhen:
          (previous, current) =>
              previous.user.avatarUrl != current.user.avatarUrl,
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // TODO: Implement change avatar functionality
          },
          child: SizedBox(
            width: double.infinity,
            child: CommonCircleNetworkImage(
              imageUrl: state.user.avatarUrl,
              enablePadding: false,
              size: Dimens.d80.responsive(),
              placeHolderType: ImagePlaceHolderType.user,
            ),
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
    return CommonContainer2(
      child: Column(
        children: [
          SizedBox(height: Dimens.d40.responsive()),
          BlocBuilder<AccountBloc, AccountState>(
            buildWhen:
                (previous, current) =>
                    previous.user.fullName != current.user.fullName,
            builder: (context, state) {
              return Text(
                state.user.fullName,
                style: AppTextStyles.s18wBoldBlack(),
              );
            },
          ),
          BlocBuilder<AccountBloc, AccountState>(
            buildWhen:
                (previous, current) =>
                    previous.user.email != current.user.email,
            builder: (context, state) {
              return Text(
                state.user.email,
                style: AppTextStyles.s14wNormalBlack(),
              );
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
              //TODO: Implement change password functionality
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
    return CommonContainer2(
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
              getIt.get<AppNavigator>().push(const AppRouteInfo.wallets());
            },
          ),
          CommonLine(
            margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          ),
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
              getIt.get<AppNavigator>().push(const AppRouteInfo.categories());
            },
          ),
        ],
      ),
    );
  }
}

class _SupportiveWidget extends StatelessWidget {
  const _SupportiveWidget();

  @override
  Widget build(BuildContext context) {
    return CommonContainer2(
      child: Column(
        children: [
          CommonForwardButton(
            title: S.current.settings,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Icon(
              Icons.settings,
              size: Dimens.d24.responsive(),
              color: darkGreyColor,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimens.d16.responsive()),
              topRight: Radius.circular(Dimens.d16.responsive()),
            ),
            onTap: () {
              // TODO: Implement settings functionality
            },
          ),
          CommonLine(
            margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          ),
          CommonForwardButton(
            title: S.current.help,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Icon(
              Icons.help_outline_rounded,
              size: Dimens.d24.responsive(),
              color: darkGreyColor,
            ),
            onTap: () {
              // TODO: Implement help functionality
            },
          ),
          CommonLine(
            margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          ),
          CommonForwardButton(
            title: S.current.about,
            showBorder: false,
            color: surfaceColor,
            leadingIcon: Icon(
              Icons.info_outline_rounded,
              size: Dimens.d24.responsive(),
              color: darkGreyColor,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(Dimens.d16.responsive()),
              bottomRight: Radius.circular(Dimens.d16.responsive()),
            ),
            onTap: () {
              // TODO: Implement about functionality
            },
          ),
        ],
      ),
    );
  }
}
