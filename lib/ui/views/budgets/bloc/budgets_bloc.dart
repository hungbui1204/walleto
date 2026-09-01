import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/ui/ui.dart';

part 'budgets_event.dart';
part 'budgets_state.dart';
part 'budgets_bloc.freezed.dart';

/// Stub for [BasePageState] — budgets UI/API come after a product requirement.
/// No handlers (same pattern as [MainBloc]); do not invent CRUD here.
@injectable
class BudgetsBloc extends BaseBloc<BudgetsEvent, BudgetsState> {
  BudgetsBloc() : super(BudgetsState());
}
