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

class _HomeViewState extends BasePageState<HomeView, HomeBloc>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    bloc.add(const HomeViewInitialized());
    super.initState();
  }

  @override
  Widget buildPageLoading() => const HomeLoadingShimmer();

  @override
  Widget buildPageListeners({required Widget child}) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) {
        return previous.needReloadStatisticalCharts !=
                current.needReloadStatisticalCharts &&
            current.needReloadStatisticalCharts;
      },
      listener: (context, state) {
        bloc.add(const HomeViewInitialized());
        appBloc.add(
          const StatisticalChartsReloaded(needReloadStatisticalCharts: false),
        );
      },
      child: child,
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: CommonAppBar(title: S.current.home),
      body: NoirScaffoldBody(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Dimens.d8.responsive()),
                const _NoirBalanceHero(),
                SizedBox(height: Dimens.d16.responsive()),
                const _GlassFlowRow(),
                SizedBox(height: Dimens.d16.responsive()),
                const _AllWalletsWidget(),
                SizedBox(height: Dimens.d16.responsive()),
                StatisticWidget(tabController: _tabController),
                SizedBox(height: Dimens.d16.responsive()),
                const _RecentTransactionsWidget(),
                SizedBox(height: Dimens.d28.responsive()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoirBalanceHero extends StatelessWidget {
  const _NoirBalanceHero();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) => previous.wallets != current.wallets,
      builder: (context, state) {
        final wallets = state.wallets;
        final total = wallets.fold<double>(0, (sum, w) => sum + w.amount);
        final currencyCode =
            wallets.isNotEmpty ? wallets.first.currencyCode : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.totalBalance.toUpperCase(),
              style: AppThemes.amount(
                fontSize: Dimens.d11.responsive(),
                fontWeight: FontWeight.w500,
                color: darkGreyColor,
              ).copyWith(letterSpacing: 1.6),
            ),
            SizedBox(height: Dimens.d10.responsive()),
            CommonAmountWithSymbol(
              amount: total,
              currencyCode: currencyCode,
              textStyle: AppThemes.amount(
                fontSize: Dimens.d40.responsive(),
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            SizedBox(height: Dimens.d8.responsive()),
            const AccentRule(),
          ],
        );
      },
    );
  }
}

class _GlassFlowRow extends StatelessWidget {
  const _GlassFlowRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (previous, current) => previous.wallets != current.wallets,
      builder: (context, appState) {
        final fallbackCurrency =
            appState.wallets.isNotEmpty
                ? appState.wallets.first.currencyCode
                : '';

        return BlocBuilder<HomeBloc, HomeState>(
          buildWhen:
              (previous, current) =>
                  previous.monthSummaryStats != current.monthSummaryStats,
          builder: (context, homeState) {
            final current =
                homeState.monthSummaryStats.isNotEmpty
                    ? homeState.monthSummaryStats.first
                    : const MonthSummaryStat();
            final currency =
                homeState.defaultCurrencyCode.isNotEmpty
                    ? homeState.defaultCurrencyCode
                    : fallbackCurrency;

            return Row(
              children: [
                Expanded(
                  child: _GlassChip(
                    label: S.current.income,
                    amount: current.totalIncome,
                    currencyCode: currency,
                    valueColor: greenColor,
                  ),
                ),
                SizedBox(width: Dimens.d12.responsive()),
                Expanded(
                  child: _GlassChip(
                    label: S.current.expense,
                    amount: current.totalExpense,
                    currencyCode: currency,
                    valueColor: redColor,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.valueColor,
  });

  final String label;
  final double amount;
  final String currencyCode;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      decoration: AppDecorations.glassPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FlowIconCircle(
                color: valueColor,
                isIncome: valueColor == greenColor,
              ),
              SizedBox(width: Dimens.d10.responsive()),
              Expanded(
                child: Text(label, style: AppTextStyles.s12wNormalGrey()),
              ),
            ],
          ),
          SizedBox(height: Dimens.d10.responsive()),
          CommonAmountWithSymbol(
            amount: amount,
            currencyCode: currencyCode,
            textStyle: AppThemes.amount(
              fontSize: Dimens.d16.responsive(),
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowIconCircle extends StatelessWidget {
  const _FlowIconCircle({required this.color, required this.isIncome});

  final Color color;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimens.d32.responsive(),
      height: Dimens.d32.responsive(),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(
        isIncome ? Icons.south_east : Icons.north_east,
        size: Dimens.d16.responsive(),
        color: color,
      ),
    );
  }
}

class _AllWalletsWidget extends StatelessWidget {
  const _AllWalletsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonTitledPanel(
      titleWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(S.current.allWallets, style: AppTextStyles.s16wBoldBlack()),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.read<AppNavigator>().push(const AppRouteInfo.wallets());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimens.d8.responsive(),
                horizontal: Dimens.d4.responsive(),
              ),
              child: Text(
                S.current.seeAll,
                style: AppTextStyles.s13wNormalGrey(),
              ),
            ),
          ),
        ],
      ),
      contentWidget: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previous, current) => previous.wallets != current.wallets,
        builder: (context, state) {
          if (state.wallets.isEmpty) {
            return CommonEmptyPanel(
              icon: Icons.account_balance_wallet_outlined,
              message: S.current.createYourFirstWallet,
              actionLabel: S.current.createWallet,
              onAction: () {
                context.read<AppNavigator>().push(
                  const AppRouteInfo.createWallet(),
                );
              },
            );
          }

          final count = state.wallets.length.clamp(0, 3);

          return ListView.separated(
            itemCount: count,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _WalletInfoWidget(state.wallets[index]);
            },
            separatorBuilder: (context, index) {
              return const CommonLine(color: frameColor);
            },
          );
        },
      ),
    );
  }
}

class _WalletInfoWidget extends StatelessWidget {
  const _WalletInfoWidget(this.wallet);

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () {
        context.read<AppNavigator>().push(AppRouteInfo.editWallet(wallet: wallet));
      },
      semanticLabel: wallet.name,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
        child: Row(
          children: [
            CommonCircleNetworkImage(
              imageUrl: wallet.iconUrl,
              placeHolderType: ImagePlaceHolderType.wallet,
            ),
            SizedBox(width: Dimens.d10.responsive()),
            Expanded(
              child: Text(wallet.name, style: AppTextStyles.s16wNormalBlack()),
            ),
            CommonAmountWithSymbol(
              amount: wallet.amount,
              currencyCode: wallet.currencyCode,
            ),
            SizedBox(width: Dimens.d4.responsive()),
            Icon(
              Icons.chevron_right,
              size: Dimens.d20.responsive(),
              color: darkGreyColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsWidget extends StatelessWidget {
  const _RecentTransactionsWidget();

  @override
  Widget build(BuildContext context) {
    return CommonTitledPanel(
      titleWidget: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          S.current.recentTransactions,
          style: AppTextStyles.s16wBoldBlack(),
        ),
      ),
      contentWidget: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.recentTransactions != current.recentTransactions;
        },
        builder: (context, state) {
          if (state.recentTransactions.isEmpty) {
            return CommonEmptyPanel(
              icon: Icons.receipt_long_outlined,
              message: S.current.noRecentTransactions,
              actionLabel: S.current.addTransaction,
              onAction: () {
                context.read<AppNavigator>().push(
                  const AppRouteInfo.createTransaction(),
                );
              },
            );
          }

          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.recentTransactions.length,
            itemBuilder: (context, index) {
              return _RecentTransactionWidget(state.recentTransactions[index]);
            },
            separatorBuilder: (context, index) {
              return const CommonLine(color: frameColor);
            },
          );
        },
      ),
    );
  }
}

class _RecentTransactionWidget extends StatelessWidget {
  const _RecentTransactionWidget(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: Dimens.d44.responsive()),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          context.read<AppNavigator>().push(
            AppRouteInfo.transactionDetail(transaction: transaction),
          );
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CommonCircleNetworkImage(
                  imageUrl: transaction.category.iconUrl,
                ),
                Positioned(
                  bottom: 0,
                  right: -6,
                  child: CommonCircleNetworkImage(
                    imageUrl: transaction.wallet.iconUrl,
                    placeHolderType: ImagePlaceHolderType.wallet,
                    backgroundColor: primaryShadeColor,
                    size: Dimens.d16.responsive(),
                  ),
                ),
              ],
            ),
            SizedBox(width: Dimens.d16.responsive()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.name,
                    style: AppTextStyles.s14wBoldBlack(),
                  ),
                  Text(
                    transaction.transactionDate!.toStringWithFormat(
                      DateTimeFormatConstants.dayMonthYearFormat,
                    ),
                    style: AppThemes.amount(
                      fontSize: Dimens.d11.responsive(),
                      fontWeight: FontWeight.w500,
                      color: darkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            CommonAmountWithSymbol(
              amount: transaction.amount,
              currencyCode: transaction.currencyCode,
              textStyle: AppThemes.amount(
                fontSize: Dimens.d14.responsive(),
                color:
                    transaction.type == CategoryType.expense
                        ? redColor
                        : greenColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
