import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

void main() {
  const usageMapper = AiChatUsageDataMapper(AiChatPromptTokensDetailsDataMapper());
  const responseMapper = AiChatResponseDataMapper(usageMapper, AiChatDebugContextDataMapper());
  const mapper = AiChatStreamEventDataMapper(responseMapper);

  test('maps a delta frame onto an incremental stream event', () {
    const data = AiChatStreamEventData(type: 'delta', content: 'Hello');

    expect(mapper.mapToEntity(data), const AiChatStreamEvent.delta(content: 'Hello'));
  });

  test('maps a done frame onto a completed send result', () {
    const data = AiChatStreamEventData(
      type: 'done',
      reply: 'Hello there',
      model: '@cf/meta/llama-3.1-8b-instruct',
      usage: AiChatUsageData(promptTokens: 4, completionTokens: 2, totalTokens: 6),
      debugContext: AiChatDebugContextData(baseCurrency: 'VND', walletCount: 1),
    );

    final event = mapper.mapToEntity(data);

    expect(
      event,
      const AiChatStreamEvent.completed(
        result: AiChatSendResult(
          message: AiChatMessage(
            role: AiChatRole.assistant,
            content: 'Hello there',
            model: '@cf/meta/llama-3.1-8b-instruct',
          ),
          usage: AiChatUsage(promptTokens: 4, completionTokens: 2, totalTokens: 6),
          debugContext: AiChatDebugContext(baseCurrency: 'VND', walletCount: 1),
        ),
      ),
    );
  });

  test('maps persist ids from a persisted frame onto a persisted event', () {
    const data = AiChatStreamEventData(
      type: 'persisted',
      userMessageId: 10,
      assistantMessageId: 11,
    );

    expect(
      mapper.mapToEntity(data),
      const AiChatStreamEvent.persisted(userMessageId: 10, assistantMessageId: 11),
    );
  });

  test('throws decodeError for an unknown frame type', () {
    expect(
      () => mapper.mapToEntity(const AiChatStreamEventData(type: 'start')),
      throwsA(
        isA<RemoteException>().having((e) => e.kind, 'kind', RemoteExceptionKind.decodeError),
      ),
    );
  });

  test('maps a status frame onto a status stream event', () {
    const data = AiChatStreamEventData(
      type: AiChatSseConstants.typeStatus,
      status: AiChatSseConstants.statusLoadingContext,
    );

    expect(
      mapper.mapToEntity(data),
      const AiChatStreamEvent.status(status: AiChatSseConstants.statusLoadingContext),
    );
  });
}
