import 'package:dartx/dartx.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

part 'create_wallet_event.dart';
part 'create_wallet_state.dart';
part 'create_wallet_bloc.freezed.dart';

@injectable
class CreateWalletBloc extends BaseBloc<CreateWalletEvent, CreateWalletState> {
  CreateWalletBloc(this._createWalletUseCase) : super(const CreateWalletState()) {
    on<CreateWalletViewInitiated>(_onCreateWalletViewInitiated, transformer: log());
    on<CreateWalletConfirmButtonPressed>(_onCreateWalletConfirmButtonPressed, transformer: log());
    on<CreateWalletNameInputChanged>(_onCreateWalletNameInputChanged, transformer: log());
    on<CreateWalletInitialBalanceInputChanged>(
      _onCreateWalletInitialBalanceInputChanged,
      transformer: log(),
    );
    on<CreateWalletIconChanged>(_onCreateWalletIconChanged, transformer: log());
    on<CreateWalletCurrencyChanged>(_onCreateWalletCurrencyChanged, transformer: log());
  }

  final CreateWalletUseCase _createWalletUseCase;

  double? _parseInitialBalance(String value) {
    if (value.trim().isEmpty) {
      return 0;
    }

    return double.tryParse(value);
  }

  bool _isConfirmButtonEnabled({required String walletName, required String initialBalance}) {
    final balance = _parseInitialBalance(initialBalance);

    return walletName.trim().isNotEmpty && balance != null && balance.isFinite && balance >= 0;
  }

  void _onCreateWalletViewInitiated(
    CreateWalletViewInitiated event,
    Emitter<CreateWalletState> emit,
  ) {
    final defaultCurrency = appBloc.state.currencies.firstOrNullWhere(
      (currency) => currency.code == AppConstants.defaultCurrencyCode,
    );

    emit(state.copyWith(selectedCurrency: defaultCurrency));
  }

  Future<void> _onCreateWalletConfirmButtonPressed(
    CreateWalletConfirmButtonPressed event,
    Emitter<CreateWalletState> emit,
  ) async {
    final initialBalance = _parseInitialBalance(state.initialBalance);
    if (!_isConfirmButtonEnabled(
          walletName: state.walletName,
          initialBalance: state.initialBalance,
        ) ||
        initialBalance == null) {
      return;
    }

    await runBlocCatching(
      action: () async {
        final wallet = Wallet(
          name: state.walletName,
          amount: initialBalance,
          iconUrl: state.iconUrl,
          currencyCode: state.selectedCurrency?.code ?? '',
        );

        await _createWalletUseCase.execute(CreateWalletInput(wallet: wallet));

        // Replace to main view if current route is from login
        // Otherwise, just pop current view and fetch wallets again
        if (navigator.getCurrentRouteNames().contains(WalletsRoute.name)) {
          appBloc.add(const DataFetched(walletsFetched: true));
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
      state.copyWith(
        walletName: event.walletName,
        isConfirmButtonEnabled: _isConfirmButtonEnabled(
          walletName: event.walletName,
          initialBalance: state.initialBalance,
        ),
      ),
    );
  }

  void _onCreateWalletInitialBalanceInputChanged(
    CreateWalletInitialBalanceInputChanged event,
    Emitter<CreateWalletState> emit,
  ) {
    emit(
      state.copyWith(
        initialBalance: event.initialBalance,
        isConfirmButtonEnabled: _isConfirmButtonEnabled(
          walletName: state.walletName,
          initialBalance: event.initialBalance,
        ),
      ),
    );
  }

  void _onCreateWalletIconChanged(CreateWalletIconChanged event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(iconUrl: event.iconUrl));
  }

  void _onCreateWalletCurrencyChanged(
    CreateWalletCurrencyChanged event,
    Emitter<CreateWalletState> emit,
  ) {
    if (state.selectedCurrency == event.currency) return;

    emit(state.copyWith(selectedCurrency: event.currency));
  }
}
