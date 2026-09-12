import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class AiChatStreamEventDataMapper extends BaseDataMapper<AiChatStreamEventData, AiChatStreamEvent> {
  const AiChatStreamEventDataMapper(this._aiChatResponseDataMapper);

  final AiChatResponseDataMapper _aiChatResponseDataMapper;

  @override
  AiChatStreamEvent mapToEntity(AiChatStreamEventData? data) {
    final type = data?.type;

    if (type == AiChatSseConstants.typeStatus) {
      return AiChatStreamEvent.status(status: data?.status ?? '');
    }

    if (type == AiChatSseConstants.typeDelta) {
      return AiChatStreamEvent.delta(content: data?.content ?? '');
    }

    if (type == AiChatSseConstants.typeDone) {
      final result = _aiChatResponseDataMapper.mapToEntity(
        AiChatResponseData(
          reply: data?.reply,
          model: data?.model,
          usage: data?.usage,
          debugContext: data?.debugContext,
        ),
      );

      return AiChatStreamEvent.completed(result: result);
    }

    if (type == AiChatSseConstants.typePersisted) {
      return AiChatStreamEvent.persisted(
        userMessageId: data?.userMessageId ?? 0,
        assistantMessageId: data?.assistantMessageId ?? 0,
      );
    }

    throw const RemoteException(kind: RemoteExceptionKind.decodeError);
  }
}
