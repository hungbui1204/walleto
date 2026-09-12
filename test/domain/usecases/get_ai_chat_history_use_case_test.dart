import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late GetAiChatHistoryUseCase useCase;

  const messages = [
    AiChatMessage(id: 2, role: AiChatRole.assistant, content: 'Hi'),
    AiChatMessage(id: 1, content: 'Hello'),
  ];

  setUp(() {
    repository = _MockRepository();
    useCase = GetAiChatHistoryUseCase(repository);
  });

  test('returns history from the repository with the given paging', () async {
    when(
      () => repository.getAiChatHistory(offset: 20, limit: 10),
    ).thenAnswer((_) async => messages);

    final output = await useCase.execute(const GetAiChatHistoryInput(offset: 20, limit: 10));

    expect(output.messages, messages);
    verify(() => repository.getAiChatHistory(offset: 20, limit: 10)).called(1);
  });

  test('uses default paging when the input omits offset and limit', () async {
    when(
      () => repository.getAiChatHistory(offset: 0, limit: PagingConstants.aiChatHistoryPageSize),
    ).thenAnswer((_) async => messages);

    final output = await useCase.execute(const GetAiChatHistoryInput());

    expect(output.messages, messages);
    verify(
      () => repository.getAiChatHistory(offset: 0, limit: PagingConstants.aiChatHistoryPageSize),
    ).called(1);
  });

  test('propagates AppException from the repository', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.network);
    when(() => repository.getAiChatHistory(offset: 0, limit: 20)).thenThrow(exception);

    await expectLater(useCase.execute(const GetAiChatHistoryInput()), throwsA(same(exception)));
  });

  test('wraps a non-AppException in AppUncaughtException', () async {
    final cause = StateError('boom');
    when(() => repository.getAiChatHistory(offset: 0, limit: 20)).thenThrow(cause);

    await expectLater(
      useCase.execute(const GetAiChatHistoryInput()),
      throwsA(isA<AppUncaughtException>().having((e) => e.rootError, 'rootError', same(cause))),
    );
  });
}
