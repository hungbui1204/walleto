import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends BasePageState<HomeView, HomeBloc> {
  @override
  void initState() {
    bloc.add(const HomeViewInitialized());
    super.initState();
  }

  @override
  Widget buildPageListeners({required Widget child}) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.needReloadStatisticalCharts != current.needReloadStatisticalCharts &&
            current.needReloadStatisticalCharts;
      },
      listener: (context, state) {
        // Reload statistical chart when the app state indicates a need to reload
        bloc.add(const HomeViewInitialized());
        // Reset the needReloadStatisticalCharts flag
        appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: false));
      },
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.home),
      body: Padding(
        padding: EdgeInsets.all(Dimens.d16.responsive()),
        child: Column(
          children: [
            const _AllWalletsWidget(),
            SizedBox(height: Dimens.d20.responsive()),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) => previous.monthStat != current.monthStat,
              builder: (context, state) {
                return StatisticalCharts(stats: state.monthStat);
              },
            ),
            // TODO: Implement the recent transactions widget
          ],
        ),
      ),
    );
  }
}

class _AllWalletsWidget extends StatelessWidget {
  const _AllWalletsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(S.current.allWallets, style: AppTextStyles.s16wBoldBlack()),
          Text(S.current.seeAll, style: AppTextStyles.s13wNormalBlack()),
        ],
      ),
      contentWidget: Column(
        children: [
          BlocBuilder<AppBloc, AppState>(
            buildWhen: (previous, current) => previous.wallets != current.wallets,
            builder: (context, state) {
              if (state.wallets.isEmpty) return const SizedBox.shrink();
              return ListView.separated(
                itemCount: state.wallets.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _WalletInfoWidget(
                    walletName: state.wallets[index].name,
                    walletBalance: state.wallets[index].amount,
                    walletIconUrl: state.wallets[index].iconUrl,
                  );
                },
                separatorBuilder: (context, index) {
                  return const CommonLine(color: greyColor);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WalletInfoWidget extends StatelessWidget {
  const _WalletInfoWidget({
    required this.walletName,
    required this.walletBalance,
    required this.walletIconUrl,
  });

  final String walletName;
  final double walletBalance;
  final String walletIconUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CommonCircleNetworkImage(
          imageUrl: walletIconUrl,
          placeHolderType: ImagePlaceHolderType.wallet,
        ),
        SizedBox(width: Dimens.d10.responsive()),
        Text(walletName, style: AppTextStyles.s16wNormalBlack()),
        const Spacer(),
        Text(
          walletBalance.toStringWithFormat(NumberFormatConstants.amountFormat),
          style: AppTextStyles.s16wNormalBlack(),
        ),
      ],
    );
  }
}
