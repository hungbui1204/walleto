import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

@lazySingleton
class AppBloc extends BaseBloc<AppEvent, AppState> {
  AppBloc(this._signOutUseCase, this._getWalletsUseCase) : super(const AppState()) {
    on<SignOutButtonPressed>(_onSignOutButtonPressed);
    on<DataFetched>(_onDataFetched);
    on<TransactionsReloaded>(_onTransactionsReloaded);
    on<StatisticalChartsReloaded>(_onStatisticalChartsReloaded);
  }

  final SignOutUseCase _signOutUseCase;
  final GetWalletsUseCase _getWalletsUseCase;

  Future<void> _onSignOutButtonPressed(SignOutButtonPressed event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        await _signOutUseCase.execute(const SignOutInput());
      },
    );
  }

  Future<void> _onDataFetched(DataFetched event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        final walletsOutput = await _getWalletsUseCase.execute(const GetWalletsInput());

        final sortedByNameWallets =
            walletsOutput.wallets.where((wallet) => wallet.name.isNotEmpty).toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        emit(state.copyWith(wallets: sortedByNameWallets));
      },
    );
  }

  void _onTransactionsReloaded(TransactionsReloaded event, Emitter<AppState> emit) {
    emit(state.copyWith(needReloadTransactions: event.needReloadTransactions));
  }

  void _onStatisticalChartsReloaded(StatisticalChartsReloaded event, Emitter<AppState> emit) {
    emit(state.copyWith(needReloadStatisticalCharts: event.needReloadStatisticalCharts));
  }
}
