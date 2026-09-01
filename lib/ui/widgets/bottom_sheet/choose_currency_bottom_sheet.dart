import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ChooseCurrencyBottomSheet extends StatefulWidget {
  const ChooseCurrencyBottomSheet({
    super.key,
    required this.onCurrencySelected,
    this.currentCurrency,
  });

  final void Function(Currency) onCurrencySelected;
  final Currency? currentCurrency;

  @override
  State<ChooseCurrencyBottomSheet> createState() => _ChooseCurrencyBottomSheetState();
}

class _ChooseCurrencyBottomSheetState extends State<ChooseCurrencyBottomSheet> {
  late ValueNotifier<Currency?> selectedCurrencyNotifier;

  @override
  void initState() {
    selectedCurrencyNotifier = ValueNotifier(widget.currentCurrency);
    super.initState();
  }

  @override
  void dispose() {
    selectedCurrencyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimens.d16.responsive()),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.current.chooseCurrency, style: AppTextStyles.s18wBoldBlack()),
            SizedBox(height: Dimens.d20.responsive()),
            BlocBuilder<AppBloc, AppState>(
              buildWhen: (previous, current) => previous.currencies != current.currencies,
              builder: (context, state) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = state.currencies[index];

                    return ValueListenableBuilder(
                      valueListenable: selectedCurrencyNotifier,
                      builder: (context, value, child) {
                        final isSelected = value?.code == currency.code;

                        return _CurrencyWidget(
                          currency: currency,
                          isSelected: isSelected,
                          onTap: () {
                            selectedCurrencyNotifier.value = currency;
                          },
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const CommonLine(margin: EdgeInsets.zero);
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CommonButton(
                  compact: true,
                  text: S.current.save,
                  onTap: () {
                    if (selectedCurrencyNotifier.value != null) {
                      widget.onCurrencySelected.call(selectedCurrencyNotifier.value!);
                    }

                    context.read<AppNavigator>().pop();
                  },
                ),
                SizedBox(width: Dimens.d8.responsive()),
                CommonButton(
                  compact: true,
                  text: S.current.cancel,
                  backgroundColor: surfaceColor,
                  textColor: blackColor,
                  onTap: () => context.read<AppNavigator>().pop(),
                ),
              ],
            ),
            SizedBox(height: Dimens.d32.responsive()),
          ],
        ),
      ),
    );
  }
}

class _CurrencyWidget extends StatelessWidget {
  const _CurrencyWidget({required this.currency, required this.onTap, required this.isSelected});

  final Currency currency;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: ColoredBox(
        color: isSelected ? primaryShade1Color : surfaceColor,
        child: Padding(
          padding: EdgeInsets.all(Dimens.d12.responsive()),
          child: Row(
            children: [
              CommonRectangleNetworkImage(
                imageUrl: currency.iconUrl,
                height: Dimens.d30.responsive(),
                width: Dimens.d40.responsive(),
                placeHolderType: ImagePlaceHolderType.currency,
                hasBorder: false,
                backgroundColor: transParentColor,
              ),
              SizedBox(width: Dimens.d8.responsive()),
              Text(currency.name, style: AppTextStyles.s14wNormalBlack()),
            ],
          ),
        ),
      ),
    );
  }
}
