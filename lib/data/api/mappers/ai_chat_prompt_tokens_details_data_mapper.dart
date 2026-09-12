import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatPromptTokensDetailsDataMapper
    extends BaseDataMapper<AiChatPromptTokensDetailsData, AiChatPromptTokensDetails> {
  const AiChatPromptTokensDetailsDataMapper();

  @override
  AiChatPromptTokensDetails mapToEntity(AiChatPromptTokensDetailsData? data) {
    return AiChatPromptTokensDetails(cachedTokens: data?.cachedTokens ?? 0);
  }
}
