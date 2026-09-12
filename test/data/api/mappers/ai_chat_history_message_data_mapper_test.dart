import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

void main() {
  const mapper = AiChatHistoryMessageDataMapper(AiChatRoleDataMapper());

  test('maps a history row onto an AiChatMessage', () {
    const data = AiChatHistoryMessageData(
      id: 7,
      role: 'assistant',
      content: 'Saved 12%',
      model: '@cf/meta/llama-3.1-8b-instruct',
      createdAt: '2026-09-12T02:15:00.000Z',
    );

    final entity = mapper.mapToEntity(data);

    expect(entity.id, 7);
    expect(entity.role, AiChatRole.assistant);
    expect(entity.content, 'Saved 12%');
    expect(entity.model, '@cf/meta/llama-3.1-8b-instruct');
    expect(entity.createdAt, DateTime.parse('2026-09-12T02:15:00.000Z'));
  });

  test('defaults unknown or missing values', () {
    final entity = mapper.mapToEntity(null);

    expect(entity.id, 0);
    expect(entity.role, AiChatRole.user);
    expect(entity.content, '');
    expect(entity.model, '');
    expect(entity.createdAt, isNull);
  });
}
