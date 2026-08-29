import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class WalletsView extends StatefulWidget {
  const WalletsView({super.key});

  @override
  State<WalletsView> createState() => _WalletsViewState();
}

class _WalletsViewState extends State<WalletsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.myWallets),
      body: NoirScaffoldBody(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Dimens.d10.responsive()),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: S.current.createWallet,
                    onPressed: () {
                      getIt.get<AppNavigator>().push(
                        const AppRouteInfo.createWallet(),
                      );
                    },
                    icon: Assets.icons.plus.svg(
                      width: Dimens.d24.responsive(),
                      height: Dimens.d24.responsive(),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Dimens.d10.responsive()),
                BlocBuilder<AppBloc, AppState>(
                  buildWhen:
                      (previous, current) =>
                          previous.wallets != current.wallets,
                  builder: (context, state) {
                    if (state.wallets.isEmpty) {
                      return CommonEmptyPanel(
                        icon: Icons.account_balance_wallet_outlined,
                        message: S.current.createYourFirstWallet,
                        actionLabel: S.current.createWallet,
                        onAction: () {
                          getIt.get<AppNavigator>().push(
                            const AppRouteInfo.createWallet(),
                          );
                        },
                      );
                    }

                    return CommonContainer2(
                      padding: EdgeInsets.all(Dimens.d16.responsive()),
                      child: ListView.separated(
                        itemCount: state.wallets.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return CommonRow(
                            onTap: () {
                              getIt.get<AppNavigator>().push(
                                AppRouteInfo.editWallet(
                                  wallet: state.wallets[index],
                                ),
                              );
                            },
                            title: state.wallets[index].name,
                            content: state.wallets[index].amount
                                .toStringWithFormat(
                                  NumberFormatConstants.amountFormat,
                                ),
                            prefix: CommonCircleNetworkImage(
                              imageUrl: state.wallets[index].iconUrl,
                              placeHolderType: ImagePlaceHolderType.wallet,
                              backgroundColor: primaryShadeColor,
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const CommonLine(),
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
