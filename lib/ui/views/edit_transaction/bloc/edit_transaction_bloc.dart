import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/ui/ui.dart';

part 'edit_transaction_event.dart';
part 'edit_transaction_state.dart';
part 'edit_transaction_bloc.freezed.dart';

@injectable
class EditTransactionBloc extends BaseBloc<EditTransactionEvent, EditTransactionState> {
  EditTransactionBloc() : super(const EditTransactionState()) {
    on<EditTransactionViewInitiated>(_onEditTransactionViewInitiated, transformer: log());
  }

  void _onEditTransactionViewInitiated(
    EditTransactionViewInitiated event,
    Emitter<EditTransactionState> emit,
  ) {
    emit(state.copyWith(transaction: event.transaction));
  }
}
