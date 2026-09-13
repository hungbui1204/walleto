import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class WalletsView extends StatefulWidget {
  const WalletsView({super.key});

  @override
  State<WalletsView> createState() => _WalletsViewState();
}

class _WalletsViewState extends BasePageState<WalletsView, WalletsBloc> {
  @override
  void initState() {
    bloc.add(const WalletsViewInitiated());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.myWallets),
      body: NoirScaffoldBody(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            final next = appBloc.stream.first;
            appBloc.add(const DataFetched(walletsFetched: true));
            await next;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Dimens.d10.responsive()),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Pressable(
                      onTap: () {
                        navigator.push(const AppRouteInfo.createWallet());
                      },
                      semanticLabel: S.current.createWallet,
                      borderRadius: AppDecorations.chipRadius(),
                      child: SizedBox(
                        width: Dimens.d44.responsive(),
                        height: Dimens.d44.responsive(),
                        child: Center(
                          child: Assets.icons.plus.svg(
                            width: Dimens.d24.responsive(),
                            height: Dimens.d24.responsive(),
                            fit: BoxFit.cover,
                            colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: Dimens.d10.responsive()),
                  BlocBuilder<AppBloc, AppState>(
                    buildWhen: (previous, current) => previous.wallets != current.wallets,
                    builder: (context, state) {
                      if (state.wallets.isEmpty) {
                        return CommonEmptyPanel(
                          icon: Icons.account_balance_wallet_outlined,
                          message: S.current.createYourFirstWallet,
                          actionLabel: S.current.createWallet,
                          onAction: () {
                            navigator.push(const AppRouteInfo.createWallet());
                          },
                        );
                      }

                      return CommonGlassPanel(
                        padding: EdgeInsets.all(Dimens.d16.responsive()),
                        child: ListView.separated(
                          itemCount: state.wallets.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return CommonRow(
                              onTap: () {
                                navigator.push(
                                  AppRouteInfo.editWallet(wallet: state.wallets[index]),
                                );
                              },
                              title: state.wallets[index].name,
                              amount: state.wallets[index].amount,
                              currencyCode: state.wallets[index].currencyCode,
                              showChevron: true,
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
      ),
    );
  }
}
