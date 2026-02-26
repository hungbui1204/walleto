import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_top_wallet_stats_use_case.freezed.dart';

@injectable
class GetTopWalletStatsUseCase
    extends BaseFutureUseCase<GetTopWalletStatsInput, GetTopWalletStatsOutput> {
  const GetTopWalletStatsUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetTopWalletStatsOutput> buildUseCase(GetTopWalletStatsInput input) async {
    final walletStat = await _repository.getTopWalletStats(
      targetMonth: input.targetMonth,
      targetYear: input.targetYear,
      categoryType: input.categoryType,
    );

    return GetTopWalletStatsOutput(walletStat: walletStat);
  }
}

@freezed
sealed class GetTopWalletStatsInput extends BaseInput with _$GetTopWalletStatsInput {
  const GetTopWalletStatsInput._();

  const factory GetTopWalletStatsInput({
    required int targetMonth,
    required int targetYear,
    required CategoryType categoryType,
  }) = _GetTopWalletStatsInput;
}

@freezed
sealed class GetTopWalletStatsOutput extends BaseOutput with _$GetTopWalletStatsOutput {
  const GetTopWalletStatsOutput._();

  const factory GetTopWalletStatsOutput({required WalletStat walletStat}) =
      _GetTopWalletStatsOutput;
}
