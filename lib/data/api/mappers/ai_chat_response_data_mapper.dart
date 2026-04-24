import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatResponseDataMapper extends BaseDataMapper<AiChatResponseData, AiChatMessage> {
  const AiChatResponseDataMapper();

  @override
  AiChatMessage mapToEntity(AiChatResponseData? data) {
    return AiChatMessage(
      reply: data?.reply ?? '',
      model: data?.model ?? '',
      promptTokens: data?.usage?.promptTokens ?? 0,
      completionTokens: data?.usage?.completionTokens ?? 0,
      totalTokens: data?.usage?.totalTokens ?? 0,
    );
  }
}
