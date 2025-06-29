import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/ui/ui.dart';

part 'account_event.dart';
part 'account_state.dart';
part 'account_bloc.freezed.dart';

@injectable
class AccountBloc extends BaseBloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<AccountEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
