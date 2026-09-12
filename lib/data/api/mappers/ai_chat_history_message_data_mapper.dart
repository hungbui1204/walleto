import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

@injectable
class AiChatHistoryMessageDataMapper
    extends BaseDataMapper<AiChatHistoryMessageData, AiChatMessage> {
  const AiChatHistoryMessageDataMapper(this._aiChatRoleDataMapper);

  final AiChatRoleDataMapper _aiChatRoleDataMapper;

  @override
  AiChatMessage mapToEntity(AiChatHistoryMessageData? data) {
    return AiChatMessage(
      id: data?.id ?? 0,
      role: _aiChatRoleDataMapper.mapToEntity(data?.role),
      content: data?.content ?? '',
      model: data?.model ?? '',
      createdAt: data?.createdAt?.toDateTime(),
    );
  }
}
