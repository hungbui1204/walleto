import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late SendAiChatMessageUseCase useCase;

  const result = AiChatSendResult(
    message: AiChatMessage(role: AiChatRole.assistant, content: 'Hello'),
  );

  setUp(() {
    repository = _MockRepository();
    useCase = SendAiChatMessageUseCase(repository);
  });

  test('returns the send result from the repository', () async {
    when(() => repository.sendAiChatMessage(message: 'Hi')).thenAnswer((_) async => result);

    final output = await useCase.execute(const SendAiChatMessageInput(message: 'Hi'));

    expect(output.result, result);
    verify(() => repository.sendAiChatMessage(message: 'Hi')).called(1);
  });

  test('propagates AppException from the repository', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.network);
    when(() => repository.sendAiChatMessage(message: 'Hi')).thenThrow(exception);

    await expectLater(
      useCase.execute(const SendAiChatMessageInput(message: 'Hi')),
      throwsA(same(exception)),
    );
  });

  test('wraps a non-AppException in AppUncaughtException', () async {
    final cause = StateError('boom');
    when(() => repository.sendAiChatMessage(message: 'Hi')).thenThrow(cause);

    await expectLater(
      useCase.execute(const SendAiChatMessageInput(message: 'Hi')),
      throwsA(isA<AppUncaughtException>().having((e) => e.rootError, 'rootError', same(cause))),
    );
  });
}
