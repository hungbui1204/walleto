import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

@injectable
class AccountBloc extends BaseBloc<AccountEvent, AccountState> {
  AccountBloc(this._getUserInfoUseCase) : super(const AccountState()) {
    on<AccountViewInitiated>(_onAccountViewInitiated);
  }

  final GetUserInfoUseCase _getUserInfoUseCase;

  Future<void> _onAccountViewInitiated(
    AccountViewInitiated event,
    Emitter<AccountState> emit,
  ) async {
    await runBlocCatching(
      action: () async {
        final userInfoOutput = await _getUserInfoUseCase.execute(const GetUserInfoInput());

        emit(state.copyWith(user: userInfoOutput.user));
      },
    );
  }
}
