import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/domain/domain.dart';

void main() {
  const usageMapper = AiChatUsageDataMapper(AiChatPromptTokensDetailsDataMapper());
  const mapper = AiChatResponseDataMapper(usageMapper, AiChatDebugContextDataMapper());

  test('maps the function response onto an assistant send result', () {
    const data = AiChatResponseData(
      reply: 'You spent 120 this month.',
      model: '@cf/meta/llama-3.1-8b-instruct',
      usage: AiChatUsageData(promptTokens: 11, completionTokens: 22, totalTokens: 33),
      debugContext: AiChatDebugContextData(
        baseCurrency: 'USD',
        walletCount: 2,
        transactionCount: 5,
        missingRateCurrencies: ['VND'],
      ),
    );

    final result = mapper.mapToEntity(data);

    expect(result.message.role, AiChatRole.assistant);
    expect(result.message.content, 'You spent 120 this month.');
    expect(result.message.model, '@cf/meta/llama-3.1-8b-instruct');
    expect(result.usage.promptTokens, 11);
    expect(result.usage.completionTokens, 22);
    expect(result.usage.totalTokens, 33);
    expect(result.debugContext.baseCurrency, 'USD');
    expect(result.debugContext.walletCount, 2);
    expect(result.debugContext.transactionCount, 5);
    expect(result.debugContext.missingRateCurrencies, ['VND']);
  });
}
