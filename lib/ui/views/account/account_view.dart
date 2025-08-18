import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
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
      body: Padding(
        padding: EdgeInsets.only(top: Dimens.d30.responsive()),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                SizedBox(height: Dimens.d40.responsive()),
                const _AccountInfoWidget(),
                SizedBox(height: Dimens.d20.responsive()),
              ],
            ),
            const _UserCircleAvatarWidget(),
          ],
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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      decoration: BoxDecoration(
        color: primaryShade1Color,
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        border: Border.all(),
      ),
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
          const CommonLine(),
          Row(
            children: [
              Text(S.current.changePassword, style: AppTextStyles.s14wNormalBlack()),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: blackColor,
                size: Dimens.d18.responsive(),
              ),
            ],
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
    return Container(child: Column());
  }
}
