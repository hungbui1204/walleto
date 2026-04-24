import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatResponseDataMapper extends BaseDataMapper<AiChatResponseData, AiChatMessage> {
  const AiChatResponseDataMapper(this._aiChatUsageDataMapper, this._aiChatDebugContextDataMapper);

  final AiChatUsageDataMapper _aiChatUsageDataMapper;
  final AiChatDebugContextDataMapper _aiChatDebugContextDataMapper;

  @override
  AiChatMessage mapToEntity(AiChatResponseData? data) {
    return AiChatMessage(
      reply: data?.reply ?? '',
      model: data?.model ?? '',
      usage: _aiChatUsageDataMapper.mapToEntity(data?.usage),
      debugContext: _aiChatDebugContextDataMapper.mapToEntity(data?.debugContext),
    );
  }
}
