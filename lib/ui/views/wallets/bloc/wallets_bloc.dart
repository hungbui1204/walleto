import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/ui/ui.dart';

part 'wallets_event.dart';
part 'wallets_state.dart';
part 'wallets_bloc.freezed.dart';

@injectable
class WalletsBloc extends BaseBloc<WalletsEvent, WalletsState> {
  WalletsBloc() : super(const WalletsState()) {
    on<WalletsViewInitiated>(_onWalletsViewInitiated, transformer: log());
  }

  void _onWalletsViewInitiated(WalletsViewInitiated event, Emitter<WalletsState> emit) {
    appBloc.add(const DataFetched(walletsFetched: true));
  }
}
