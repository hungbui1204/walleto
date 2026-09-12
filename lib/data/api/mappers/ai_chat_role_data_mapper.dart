import 'package:injectable/injectable.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

@injectable
class AiChatRoleDataMapper extends BaseDataMapper<String, AiChatRole> with DataMapperMixin {
  const AiChatRoleDataMapper();

  @override
  AiChatRole mapToEntity(String? data) {
    return switch (data) {
      'assistant' => AiChatRole.assistant,
      _ => AiChatRole.user,
    };
  }

  @override
  String mapToData(AiChatRole entity) {
    return switch (entity) {
      AiChatRole.assistant => 'assistant',
      AiChatRole.user => 'user',
    };
  }
}
