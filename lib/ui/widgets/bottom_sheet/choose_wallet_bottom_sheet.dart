import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class ChooseWalletBottomSheet extends StatelessWidget {
  const ChooseWalletBottomSheet({
    super.key,
    required this.onWalletSelected,
    this.currentWallet,
    this.wallets,
    this.includeTotalWallet = false,
  });

  final void Function(Wallet) onWalletSelected;
  final Wallet? currentWallet;
  final List<Wallet>? wallets;
  final bool includeTotalWallet;

  @override
  Widget build(BuildContext context) {
    return CommonPickerSheet(
      title: S.current.chooseWallet,
      child:
          wallets != null
              ? _WalletList(
                wallets: _visibleWallets(wallets!),
                currentWallet: currentWallet,
                onWalletSelected: onWalletSelected,
              )
              : BlocBuilder<AppBloc, AppState>(
                buildWhen: (previous, current) => previous.wallets != current.wallets,
                builder: (context, state) {
                  return _WalletList(
                    wallets: _visibleWallets(state.wallets),
                    currentWallet: currentWallet,
                    onWalletSelected: onWalletSelected,
                  );
                },
              ),
    );
  }

  List<Wallet> _visibleWallets(List<Wallet> source) {
    if (includeTotalWallet) return source;

    return source.where((wallet) => wallet.id != AppConstants.totalWalletId).toList();
  }
}

class _WalletList extends StatelessWidget {
  const _WalletList({
    required this.wallets,
    required this.currentWallet,
    required this.onWalletSelected,
  });

  final List<Wallet> wallets;
  final Wallet? currentWallet;
  final void Function(Wallet) onWalletSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];

        return _WalletWidget(
          wallet: wallet,
          isSelected: currentWallet?.id == wallet.id,
          onTap: () {
            onWalletSelected(wallet);
            context.read<AppNavigator>().pop();
          },
        );
      },
      separatorBuilder: (context, index) => const CommonLine(margin: EdgeInsets.zero),
    );
  }
}

class _WalletWidget extends StatelessWidget {
  const _WalletWidget({required this.isSelected, required this.wallet, required this.onTap});

  final bool isSelected;
  final Wallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CommonListRow(
      onTap: onTap,
      leading: _WalletLeading(wallet: wallet),
      title: Text(wallet.name, style: AppTextStyles.s14wNormalBlack()),
      backgroundColor: isSelected ? primaryShade1Color : surfaceColor,
      trailing:
          isSelected
              ? Icon(Icons.check_rounded, color: primaryColor, size: Dimens.d20.responsive())
              : null,
    );
  }
}

class _WalletLeading extends StatelessWidget {
  const _WalletLeading({required this.wallet});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    if (wallet.id == AppConstants.totalWalletId) {
      return ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: frameColor)),
          child: Assets.icons.summation.svg(
            width: Dimens.d32.responsive(),
            height: Dimens.d32.responsive(),
          ),
        ),
      );
    }

    return CommonCircleNetworkImage(
      imageUrl: wallet.iconUrl,
      placeHolderType: ImagePlaceHolderType.wallet,
    );
  }
}
