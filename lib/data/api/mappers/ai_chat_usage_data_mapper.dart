import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatUsageDataMapper extends BaseDataMapper<AiChatUsageData, AiChatUsage> {
  const AiChatUsageDataMapper(this._aiChatPromptTokensDetailsDataMapper);

  final AiChatPromptTokensDetailsDataMapper _aiChatPromptTokensDetailsDataMapper;

  @override
  AiChatUsage mapToEntity(AiChatUsageData? data) {
    return AiChatUsage(
      promptTokens: data?.promptTokens ?? 0,
      completionTokens: data?.completionTokens ?? 0,
      totalTokens: data?.totalTokens ?? 0,
      promptTokensDetails: _aiChatPromptTokensDetailsDataMapper.mapToEntity(data?.promptTokensDetails),
    );
  }
}
