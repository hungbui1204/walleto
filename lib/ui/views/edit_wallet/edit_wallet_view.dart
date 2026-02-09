import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class EditWalletView extends StatefulWidget {
  const EditWalletView({super.key, required this.wallet});

  final Wallet wallet;

  @override
  State<EditWalletView> createState() => _EditWalletViewState();
}

class _EditWalletViewState extends BasePageState<EditWalletView, EditWalletBloc> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    bloc.add(EditWalletViewInitialized(widget.wallet));
    _amountController = TextEditingController(text: widget.wallet.amount.toStringAsFixedNoZero(1));
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        appBar: CommonAppBar(title: S.current.editWallet),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          child: Column(
            children: [
              SizedBox(height: Dimens.d20.responsive()),
              Container(
                padding: EdgeInsets.all(Dimens.d10.responsive()),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
                  border: Border.all(),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CommonCircleNetworkImage(
                          imageUrl: widget.wallet.iconUrl,
                          size: Dimens.d36.responsive(),
                          placeHolderType: ImagePlaceHolderType.wallet,
                        ),
                        SizedBox(width: Dimens.d10.responsive()),
                        Expanded(
                          child: Text(widget.wallet.name, style: AppTextStyles.s18wNormalBlack()),
                        ),
                      ],
                    ),
                    const CommonLine(),
                    Row(
                      children: [
                        Expanded(
                          child: CommonTextField2(
                            controller: _amountController,
                            hintText: S.current.initialBalance,
                            inputType: TextInputType.number,
                            maxLength: 24,
                            onChanged: (amount) {
                              bloc.add(EditWalletAmountInputChanged(amount));
                            },
                          ),
                        ),
                        CommonCurrencyContainer(currentCurrencyCode: widget.wallet.currencyCode),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimens.d30.responsive()),
              BlocBuilder<EditWalletBloc, EditWalletState>(
                buildWhen: (previous, current) {
                  return previous.isConfirmButtonEnabled != current.isConfirmButtonEnabled;
                },
                builder: (context, state) {
                  return CommonButton(
                    text: S.current.save,
                    onTap:
                        state.isConfirmButtonEnabled
                            ? () {
                              context.read<EditWalletBloc>().add(
                                const EditWalletConfirmButtonPressed(),
                              );
                            }
                            : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
