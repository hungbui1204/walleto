import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class AiChatHistoryMessageDataMapper
    extends BaseDataMapper<AiChatHistoryMessageData, AiChatHistoryMessage> {
  const AiChatHistoryMessageDataMapper();

  @override
  AiChatHistoryMessage mapToEntity(AiChatHistoryMessageData? data) {
    return AiChatHistoryMessage(
      id: data?.id ?? 0,
      userId: data?.userId ?? '',
      role: data?.role ?? '',
      content: data?.content ?? '',
      model: data?.model ?? '',
      promptTokens: data?.promptTokens ?? 0,
      completionTokens: data?.completionTokens ?? 0,
      totalTokens: data?.totalTokens ?? 0,
      createdAt: data?.createdAt?.toDateTime(),
    );
  }
}
