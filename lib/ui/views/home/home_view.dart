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

class _HomeViewState extends BasePageState<HomeView, HomeBloc> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
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
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: Dimens.d16.responsive()),
              const _AllWalletsWidget(),
              SizedBox(height: Dimens.d20.responsive()),
              _StatisticWidget(_tabController),
              SizedBox(height: Dimens.d20.responsive()),
              const _RecentTransactionsWidget(),
            ],
          ),
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

class _StatisticWidget extends StatelessWidget {
  const _StatisticWidget(this._tabController);

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(S.current.statisticalCharts, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Padding(
                padding: EdgeInsets.all(Dimens.d12.responsive()),
                child: Text(
                  S.current.monthSummary,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimens.d12.responsive()),
                child: Text(
                  S.current.spentStats,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimens.d16.responsive()),
          SizedBox(
            height: Dimens.d300.responsive(),
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (previous, current) {
                          return previous.monthSummaryStats != current.monthSummaryStats;
                        },
                        builder: (context, state) {
                          return MonthSummaryChart(stats: state.monthSummaryStats);
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (previous, current) {
                        return previous.selectedDateTime != current.selectedDateTime;
                      },
                      builder: (context, state) {
                        if (state.selectedDateTime == null) return const SizedBox.shrink();

                        return InkWell(
                          borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: Dimens.d6.responsive()),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimens.d8.responsive()),
                              border: Border.all(),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_outward_rounded, size: Dimens.d16.responsive()),
                                Assets.icons.calendar.svg(
                                  width: Dimens.d30.responsive(),
                                  height: Dimens.d30.responsive(),
                                ),
                                SizedBox(width: Dimens.d10.responsive()),
                                Text(
                                  state.selectedDateTime!.toStringWithFormat(
                                    DateTimeFormatConstants.monthYearFormat,
                                  ),
                                  style: AppTextStyles.s14wNormalBlack(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: Dimens.d20.responsive()),
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        buildWhen: (previous, current) {
                          return previous.categoryStats != current.categoryStats;
                        },
                        builder: (context, state) {
                          return MonthCategoryStatsChart(stats: state.categoryStats);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsWidget extends StatelessWidget {
  const _RecentTransactionsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(S.current.recentTransactions, style: AppTextStyles.s16wBoldBlack()),
      ),
      contentWidget: Column(children: []),
    );
  }
}
