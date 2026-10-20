import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'edit_wallet_event.dart';
part 'edit_wallet_state.dart';
part 'edit_wallet_bloc.freezed.dart';

@injectable
class EditWalletBloc extends BaseBloc<EditWalletEvent, EditWalletState> {
  EditWalletBloc(this._updateWalletUseCase) : super(const EditWalletState()) {
    on<EditWalletViewInitialized>(_onEditWalletViewInitialized, transformer: log());
    on<EditWalletAmountInputChanged>(_onEditWalletAmountInputChanged, transformer: log());
    on<EditWalletConfirmButtonPressed>(_onEditWalletConfirmButtonPressed, transformer: log());
  }

  final UpdateWalletUseCase _updateWalletUseCase;

  void _onEditWalletViewInitialized(
    EditWalletViewInitialized event,
    Emitter<EditWalletState> emit,
  ) {
    emit(state.copyWith(wallet: event.wallet));
  }

  void _onEditWalletAmountInputChanged(
    EditWalletAmountInputChanged event,
    Emitter<EditWalletState> emit,
  ) {
    final amount = double.tryParse(event.amount);
    emit(
      state.copyWith(
        amount: event.amount,
        isConfirmButtonEnabled:
            amount != null && amount.isFinite && amount >= 0 && amount != state.wallet.amount,
      ),
    );
  }

  Future<void> _onEditWalletConfirmButtonPressed(
    EditWalletConfirmButtonPressed event,
    Emitter<EditWalletState> emit,
  ) async {
    final newAmount = double.tryParse(state.amount);
    if (!state.isConfirmButtonEnabled ||
        newAmount == null ||
        !newAmount.isFinite ||
        newAmount < 0) {
      return;
    }

    await runBlocCatching(
      action: () async {
        await _updateWalletUseCase.execute(
          UpdateWalletInput(wallet: state.wallet.copyWith(amount: newAmount)),
        );

        appBloc.add(const DataFetched(walletsFetched: true));
        appBloc.add(const TransactionsReloaded(needReloadTransactions: true));
        appBloc.add(const StatisticalChartsReloaded(needReloadStatisticalCharts: true));

        navigator.pop();
      },
    );
  }
}
