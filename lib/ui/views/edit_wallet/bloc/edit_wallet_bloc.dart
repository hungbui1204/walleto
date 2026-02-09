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
    on<EditWalletViewInitialized>(_onEditWalletViewInitialized);
    on<EditWalletAmountInputChanged>(_onEditWalletAmountInputChanged);
    on<EditWalletConfirmButtonPressed>(_onEditWalletConfirmButtonPressed);
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
    emit(
      state.copyWith(
        amount: event.amount,
        isConfirmButtonEnabled:
            event.amount.isNotEmpty && (double.tryParse(event.amount) ?? 0) != state.wallet.amount,
      ),
    );
  }

  Future<void> _onEditWalletConfirmButtonPressed(
    EditWalletConfirmButtonPressed event,
    Emitter<EditWalletState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final newAmount = double.tryParse(state.amount) ?? 0;

        await _updateWalletUseCase.execute(
          UpdateWalletInput(wallet: state.wallet.copyWith(amount: newAmount)),
        );

        appBloc.add(const DataFetched(walletsFetched: true));

        navigator.pop();
      },
    );
  }
}
