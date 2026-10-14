import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

part 'app_event.dart';
part 'app_state.dart';
part 'app_bloc.freezed.dart';

@lazySingleton
class AppBloc extends BaseBloc<AppEvent, AppState> {
  AppBloc(
    this._signOutUseCase,
    this._getWalletsUseCase,
    this._getCurrenciesUseCase,
    this._getUserDefaultCurrencyUseCase,
    this._updateUserDefaultCurrencyUseCase,
    this._setAppThemePreferenceUseCase,
    this._isLoggedInUseCase,
  ) : super(const AppState()) {
    on<SignOutButtonPressed>(_onSignOutButtonPressed, transformer: log());
    on<UserSessionCleared>(_onUserSessionCleared, transformer: log());
    on<SessionValidationRequested>(_onSessionValidationRequested, transformer: log());
    on<DataFetched>(_onDataFetched, transformer: log());
    on<TransactionsReloaded>(_onTransactionsReloaded, transformer: log());
    on<StatisticalChartsReloaded>(_onStatisticalChartsReloaded, transformer: log());
    on<UserDefaultCurrencyUpdated>(_onUserDefaultCurrencyUpdated, transformer: log());
    on<GetUserDefaultCurrency>(_onGetUserDefaultCurrency, transformer: log());
    on<AppThemePreferenceInitialized>(_onAppThemePreferenceInitialized, transformer: log());
    on<AppThemePreferenceSelected>(_onAppThemePreferenceSelected, transformer: log());
  }

  final SignOutUseCase _signOutUseCase;
  final GetWalletsUseCase _getWalletsUseCase;
  final GetCurrenciesUseCase _getCurrenciesUseCase;
  final GetUserDefaultCurrencyUseCase _getUserDefaultCurrencyUseCase;
  final UpdateUserDefaultCurrencyUseCase _updateUserDefaultCurrencyUseCase;
  final SetAppThemePreferenceUseCase _setAppThemePreferenceUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;

  Future<void> clearUserSessionData() {
    final completer = Completer<void>();
    add(UserSessionCleared(completer));
    return completer.future;
  }

  void _clearUserSessionData(Emitter<AppState> emit) {
    emit(
      state.copyWith(
        totalBalance: 0,
        wallets: const [],
        userDefaultCurrency: const Currency(),
        needReloadTransactions: false,
        needReloadStatisticalCharts: false,
        sessionGeneration: state.sessionGeneration + 1,
      ),
    );
  }

  Future<void> _onUserSessionCleared(UserSessionCleared event, Emitter<AppState> emit) async {
    _clearUserSessionData(emit);
    if (!event.completer.isCompleted) event.completer.complete();
  }

  Future<void> _onSessionValidationRequested(
    SessionValidationRequested event,
    Emitter<AppState> emit,
  ) async {
    if (navigator.getCurrentRouteNames(useRootNavigator: true).contains(LoginRoute.name)) return;

    await runBlocCatching(
      action: () async {
        final output = await _isLoggedInUseCase.execute(const IsLoggedInInput());
        if (!output.isLoggedIn) {
          _clearUserSessionData(emit);
          await navigator.replace(const AppRouteInfo.login());
        }
      },
    );
  }

  void _onAppThemePreferenceInitialized(
    AppThemePreferenceInitialized event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(themePreference: event.preference, isThemePreferenceInitialized: true));
  }

  Future<void> _onAppThemePreferenceSelected(
    AppThemePreferenceSelected event,
    Emitter<AppState> emit,
  ) async {
    if (event.preference == state.themePreference || state.isThemePreferenceSaving) return;

    emit(state.copyWith(isThemePreferenceSaving: true));
    await runBlocCatching(
      action: () async {
        await _setAppThemePreferenceUseCase.execute(
          SetAppThemePreferenceInput(preference: event.preference),
        );
        emit(state.copyWith(themePreference: event.preference));
      },
      doOnError: (error) async {
        emit(state.copyWith(isThemePreferenceSaving: false));
      },
      doOnSuccessOrError: () async {
        emit(state.copyWith(isThemePreferenceSaving: false));
      },
    );
  }

  Future<void> _onSignOutButtonPressed(SignOutButtonPressed event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        final output = await _signOutUseCase.execute(const SignOutInput());
        _clearUserSessionData(emit);
        await navigator.replace(const AppRouteInfo.login());
        if (!output.serverSessionRevoked && !output.retainedForBiometric) {
          navigator.showErrorSnackBar(S.current.serverSignOutNotConfirmed);
        }
      },
    );
  }

  Future<void> _onDataFetched(DataFetched event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        final sessionGeneration = state.sessionGeneration;
        // Fetch wallets
        if (event.walletsFetched) {
          final walletsOutput = await _getWalletsUseCase.execute(const GetWalletsInput());
          if (sessionGeneration != state.sessionGeneration) return;

          final sortedByNameWallets =
              walletsOutput.wallets.where((wallet) => wallet.name.isNotEmpty).toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          emit(state.copyWith(wallets: sortedByNameWallets));

          final defaultCurrencyOutput = await _getUserDefaultCurrencyUseCase.execute(
            const GetUserDefaultCurrencyInput(),
          );
          if (sessionGeneration != state.sessionGeneration) return;
          emit(state.copyWith(userDefaultCurrency: defaultCurrencyOutput.currency));
        }

        // Fetch currencies
        if (event.currenciesFetched) {
          final currenciesOutput = await _getCurrenciesUseCase.execute(const GetCurrenciesInput());
          if (sessionGeneration != state.sessionGeneration) return;

          emit(state.copyWith(currencies: currenciesOutput.currencies));
        }
      },
    );
  }

  void _onTransactionsReloaded(TransactionsReloaded event, Emitter<AppState> emit) {
    emit(state.copyWith(needReloadTransactions: event.needReloadTransactions));
  }

  void _onStatisticalChartsReloaded(StatisticalChartsReloaded event, Emitter<AppState> emit) {
    emit(state.copyWith(needReloadStatisticalCharts: event.needReloadStatisticalCharts));
  }

  Future<void> _onGetUserDefaultCurrency(
    GetUserDefaultCurrency event,
    Emitter<AppState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final output = await _getUserDefaultCurrencyUseCase.execute(
          const GetUserDefaultCurrencyInput(),
        );

        emit(state.copyWith(userDefaultCurrency: output.currency));
      },
    );
  }

  Future<void> _onUserDefaultCurrencyUpdated(
    UserDefaultCurrencyUpdated event,
    Emitter<AppState> emit,
  ) async {
    if (event.newCurrency.code == state.userDefaultCurrency.code) {
      return;
    }

    if (!event.persist) {
      emit(state.copyWith(userDefaultCurrency: event.newCurrency));
      return;
    }

    await runBlocCatching(
      action: () async {
        await _updateUserDefaultCurrencyUseCase.execute(
          UpdateUserDefaultCurrencyInput(currencyCode: event.newCurrency.code),
        );
        emit(state.copyWith(userDefaultCurrency: event.newCurrency));
      },
    );
  }
}
