import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

class _MockRepository extends Mock implements Repository {}

void main() {
  late _MockRepository repository;
  late SendAiChatMessageUseCase useCase;

  const delta = AiChatStreamEvent.delta(content: 'Hello');
  const completed = AiChatStreamEvent.completed(
    result: AiChatSendResult(message: AiChatMessage(role: AiChatRole.assistant, content: 'Hello')),
  );

  setUpAll(() {
    registerFallbackValue(AppCancelToken());
  });

  setUp(() {
    repository = _MockRepository();
    useCase = SendAiChatMessageUseCase(repository);
  });

  test('forwards stream events from the repository', () async {
    when(
      () => repository.sendAiChatMessage(message: 'Hi', cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) => Stream<AiChatStreamEvent>.fromIterable([delta, completed]));

    await expectLater(
      useCase.execute(const SendAiChatMessageInput(message: 'Hi')),
      emitsInOrder([
        const SendAiChatMessageOutput(event: delta),
        const SendAiChatMessageOutput(event: completed),
        emitsDone,
      ]),
    );
    verify(
      () => repository.sendAiChatMessage(message: 'Hi', cancelToken: any(named: 'cancelToken')),
    ).called(1);
  });

  test('forwards the cancel token to the repository', () async {
    final cancelToken = AppCancelToken();
    when(
      () => repository.sendAiChatMessage(message: 'Hi', cancelToken: cancelToken),
    ).thenAnswer((_) => Stream<AiChatStreamEvent>.fromIterable([delta, completed]));

    await expectLater(
      useCase.execute(SendAiChatMessageInput(message: 'Hi', cancelToken: cancelToken)),
      emitsInOrder([
        const SendAiChatMessageOutput(event: delta),
        const SendAiChatMessageOutput(event: completed),
        emitsDone,
      ]),
    );
    verify(() => repository.sendAiChatMessage(message: 'Hi', cancelToken: cancelToken)).called(1);
  });

  test('propagates AppException from the repository stream', () async {
    const exception = RemoteException(kind: RemoteExceptionKind.network);
    when(
      () => repository.sendAiChatMessage(message: 'Hi', cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) => Stream<AiChatStreamEvent>.error(exception));

    await expectLater(
      useCase.execute(const SendAiChatMessageInput(message: 'Hi')),
      emitsError(same(exception)),
    );
  });

  test('wraps a non-AppException in AppUncaughtException', () async {
    final cause = StateError('boom');
    when(
      () => repository.sendAiChatMessage(message: 'Hi', cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) => Stream<AiChatStreamEvent>.error(cause));

    await expectLater(
      useCase.execute(const SendAiChatMessageInput(message: 'Hi')),
      emitsError(isA<AppUncaughtException>().having((e) => e.rootError, 'rootError', same(cause))),
    );
  });
}
