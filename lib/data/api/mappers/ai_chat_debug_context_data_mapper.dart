import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatDebugContextDataMapper extends BaseDataMapper<AiChatDebugContextData, AiChatDebugContext> {
  const AiChatDebugContextDataMapper();

  @override
  AiChatDebugContext mapToEntity(AiChatDebugContextData? data) {
    return AiChatDebugContext(
      baseCurrency: data?.baseCurrency ?? '',
      walletCount: data?.walletCount ?? 0,
      transactionCount: data?.transactionCount ?? 0,
      missingRateCurrencies: data?.missingRateCurrencies ?? const <String>[],
    );
  }
}
