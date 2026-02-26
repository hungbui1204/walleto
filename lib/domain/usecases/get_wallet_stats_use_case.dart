import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_wallet_stats_use_case.freezed.dart';

@injectable
class GetWalletStatsUseCase extends BaseFutureUseCase<GetWalletStatsInput, GetWalletStatsOutput> {
  const GetWalletStatsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetWalletStatsOutput> buildUseCase(GetWalletStatsInput input) async {
    final stats = await _repository.getWalletStats(
      targetMonth: input.targetMonth,
      targetYear: input.targetYear,
      categoryType: input.categoryType,
    );

    return GetWalletStatsOutput(stats: stats);
  }
}

@freezed
sealed class GetWalletStatsInput extends BaseInput with _$GetWalletStatsInput {
  const GetWalletStatsInput._();

  const factory GetWalletStatsInput({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) = _GetWalletStatsInput;
}

@freezed
sealed class GetWalletStatsOutput extends BaseOutput with _$GetWalletStatsOutput {
  const GetWalletStatsOutput._();
  const factory GetWalletStatsOutput({@Default(<WalletStat>[]) List<WalletStat> stats}) =
      _GetWalletStatsOutput;
}
