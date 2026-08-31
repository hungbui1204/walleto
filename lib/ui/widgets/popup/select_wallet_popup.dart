import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class SelectWalletPopup extends StatelessWidget {
  const SelectWalletPopup({
    super.key,
    required this.wallets,
    required this.onWalletSelected,
    this.selectedWallet,
  });

  final List<Wallet> wallets;
  final Wallet? selectedWallet;
  final void Function(Wallet) onWalletSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: context.mediaQuery.size.height * 0.7,
          ),
          margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d20.responsive(),
          ),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
            border: Border.all(color: frameColor),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  S.current.selectWallet,
                  style: AppTextStyles.s20wNormalBlack(),
                ),
                SizedBox(height: Dimens.d20.responsive()),
                if (wallets.first.id == AppConstants.totalWalletId)
                  _TotalWalletWidget(
                    totalWallet: wallets.first,
                    isSelected: wallets.first.id == selectedWallet?.id,
                    onWalletSelected: (p0) {
                      onWalletSelected.call(p0);
                      context.read<AppNavigator>().pop();
                    },
                  ),
                _WalletsWidget(
                  wallets: wallets,
                  selectedWallet: selectedWallet,
                  onWalletSelected: (p0) {
                    onWalletSelected.call(p0);
                    context.read<AppNavigator>().pop();
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

class _TotalWalletWidget extends StatelessWidget {
  const _TotalWalletWidget({
    required this.totalWallet,
    required this.isSelected,
    required this.onWalletSelected,
  });

  final Wallet totalWallet;
  final bool isSelected;
  final void Function(Wallet) onWalletSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onWalletSelected.call(totalWallet),
      child: Row(
        children: [
          SizedBox(
            width: Dimens.d20.responsive(),
            child:
                isSelected ? const Icon(Icons.check, color: checkColor) : null,
          ),
          SizedBox(width: Dimens.d4.responsive()),
          ClipOval(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: frameColor),
              ),
              child: Assets.icons.summation.svg(
                width: Dimens.d32.responsive(),
                height: Dimens.d32.responsive(),
              ),
            ),
          ),
          SizedBox(width: Dimens.d8.responsive()),
          Text(totalWallet.name),
          const Spacer(),
          Text(
            totalWallet.amount.toStringWithFormat(
              NumberFormatConstants.amountFormat,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletsWidget extends StatelessWidget {
  const _WalletsWidget({
    required this.wallets,
    required this.selectedWallet,
    required this.onWalletSelected,
  });

  final List<Wallet> wallets;
  final Wallet? selectedWallet;
  final void Function(Wallet) onWalletSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];

        // Skip the 'Total Wallet' item in the list
        if (wallet.id == AppConstants.totalWalletId)
          return const SizedBox.shrink();

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => onWalletSelected.call(wallet),
          child: Row(
            children: [
              SizedBox(
                width: Dimens.d20.responsive(),
                child:
                    wallet.id == selectedWallet?.id
                        ? const Icon(Icons.check, color: checkColor)
                        : null,
              ),
              SizedBox(width: Dimens.d4.responsive()),
              CommonCircleNetworkImage(
                imageUrl: wallet.iconUrl,
                placeHolderType: ImagePlaceHolderType.wallet,
              ),
              SizedBox(width: Dimens.d8.responsive()),
              Text(wallet.name),
              const Spacer(),
              Text(
                wallet.amount.toStringWithFormat(
                  NumberFormatConstants.amountFormat,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder:
          (context, index) => CommonLine(
            padding: EdgeInsets.only(left: Dimens.d24.responsive()),
          ),
    );
  }
}
