import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/ui/base/bloc/base_bloc.dart';

part 'wallets_event.dart';
part 'wallets_state.dart';
part 'wallets_bloc.freezed.dart';

class WalletsBloc extends BaseBloc<WalletsEvent, WalletsState> {
  WalletsBloc() : super(const WalletsState()) {
    on<WalletsEvent>(_onWalletsEvent, transformer: log());
  }

  void _onWalletsEvent(WalletsEvent event, Emitter<WalletsState> emit) {
    // TODO: implement event handler
  }
}
