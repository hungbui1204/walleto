import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatResponseDataMapper extends BaseDataMapper<AiChatResponseData, AiChatSendResult> {
  const AiChatResponseDataMapper(this._aiChatUsageDataMapper, this._aiChatDebugContextDataMapper);

  final AiChatUsageDataMapper _aiChatUsageDataMapper;
  final AiChatDebugContextDataMapper _aiChatDebugContextDataMapper;

  @override
  AiChatSendResult mapToEntity(AiChatResponseData? data) {
    return AiChatSendResult(
      message: AiChatMessage(
        role: AiChatRole.assistant,
        content: data?.reply ?? '',
        model: data?.model ?? '',
      ),
      usage: _aiChatUsageDataMapper.mapToEntity(data?.usage),
      debugContext: _aiChatDebugContextDataMapper.mapToEntity(data?.debugContext),
    );
  }
}
