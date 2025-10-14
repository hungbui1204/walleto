import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'create_wallet_event.dart';
part 'create_wallet_state.dart';
part 'create_wallet_bloc.freezed.dart';

@injectable
class CreateWalletBloc extends BaseBloc<CreateWalletEvent, CreateWalletState> {
  CreateWalletBloc(this._createWalletUseCase) : super(const CreateWalletState()) {
    on<CreateWalletConfirmButtonPressed>(_onCreateWalletConfirmButtonPressed);
    on<CreateWalletNameInputChanged>(_onCreateWalletNameInputChanged);
    on<CreateWalletInitialBalanceInputChanged>(_onCreateWalletInitialBalanceInputChanged);
    on<CreateWalletIconChanged>(_onCreateWalletIconChanged);
  }

  final CreateWalletUseCase _createWalletUseCase;

  bool get isConfirmButtonEnabled {
    return state.walletName.isNotEmpty && (double.tryParse(state.initialBalance) ?? 0) >= 0;
  }

  Future<void> _onCreateWalletConfirmButtonPressed(
    CreateWalletConfirmButtonPressed event,
    Emitter<CreateWalletState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final wallet = Wallet(
          name: state.walletName,
          amount: double.tryParse(state.initialBalance) ?? 0,
          iconUrl: state.iconUrl,
          // TODO: implement choosing currency
          currencyCode: 'VND',
        );

        await _createWalletUseCase.execute(CreateWalletInput(wallet: wallet));

        // Replace to main view if current route is from login
        // Otherwise, just pop current view and fetch wallets again
        if (navigator.getCurrentRouteNames().contains(WalletsRoute.name)) {
          appBloc.add(const DataFetched());
          navigator.pop();

          return;
        }
        navigator.replace(const AppRouteInfo.main());
      },
    );
  }

  void _onCreateWalletNameInputChanged(
    CreateWalletNameInputChanged event,
    Emitter<CreateWalletState> emit,
  ) {
    emit(
      state.copyWith(walletName: event.walletName, isConfirmButtonEnabled: isConfirmButtonEnabled),
    );
  }

  void _onCreateWalletInitialBalanceInputChanged(
    CreateWalletInitialBalanceInputChanged event,
    Emitter<CreateWalletState> emit,
  ) {
    emit(
      state.copyWith(
        initialBalance: event.initialBalance,
        isConfirmButtonEnabled: isConfirmButtonEnabled,
      ),
    );
  }

  void _onCreateWalletIconChanged(CreateWalletIconChanged event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(iconUrl: event.iconUrl));
  }
}
