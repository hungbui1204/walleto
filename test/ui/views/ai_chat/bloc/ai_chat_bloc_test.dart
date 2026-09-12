import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

class _MockGetAiChatHistoryUseCase extends Mock implements GetAiChatHistoryUseCase {}

class _MockSendAiChatMessageUseCase extends Mock implements SendAiChatMessageUseCase {}

class _MockAppNavigator extends Mock implements AppNavigator {}

class _MockAppBloc extends Mock implements AppBloc {}

class _MockCommonBloc extends Mock implements CommonBloc {}

class _MockExceptionHandler extends Mock implements ExceptionHandler {}

void main() {
  const olderAssistant = AiChatMessage(id: 2, role: AiChatRole.assistant, content: 'Hi');
  const olderUser = AiChatMessage(id: 1, content: 'Hello');
  const oldestAssistant = AiChatMessage(id: 4, role: AiChatRole.assistant, content: 'Earlier hi');
  const oldestUser = AiChatMessage(id: 3, content: 'First hello');
  const assistantReply = AiChatMessage(role: AiChatRole.assistant, content: 'You spent 50.');
  const sendResult = AiChatSendResult(message: assistantReply);
  const persistedAssistantReply = AiChatMessage(
    id: 102,
    role: AiChatRole.assistant,
    content: 'You spent 50.',
  );

  late _MockGetAiChatHistoryUseCase getAiChatHistoryUseCase;
  late _MockSendAiChatMessageUseCase sendAiChatMessageUseCase;
  late _MockAppNavigator navigator;
  late _MockAppBloc appBloc;
  late _MockCommonBloc commonBloc;
  late _MockExceptionHandler exceptionHandler;

  AiChatBloc buildBloc() {
    return AiChatBloc(getAiChatHistoryUseCase, sendAiChatMessageUseCase)
      ..navigator = navigator
      ..disposeBag = DisposeBag()
      ..appBloc = appBloc
      ..commonBloc = commonBloc
      ..exceptionHandler = exceptionHandler
      ..exceptionMessageMapper = const ExceptionMessageMapper();
  }

  setUpAll(() {
    registerFallbackValue(const GetAiChatHistoryInput());
    registerFallbackValue(const SendAiChatMessageInput(message: ''));
    registerFallbackValue(const AppRouteInfo.main());
    registerFallbackValue(const DataFetched());
    registerFallbackValue(const LoadingVisibilityEmitted(isLoading: false));
  });

  setUp(() {
    getAiChatHistoryUseCase = _MockGetAiChatHistoryUseCase();
    sendAiChatMessageUseCase = _MockSendAiChatMessageUseCase();
    navigator = _MockAppNavigator();
    appBloc = _MockAppBloc();
    commonBloc = _MockCommonBloc();
    exceptionHandler = _MockExceptionHandler();

    when(() => appBloc.state).thenReturn(const AppState());
    when(() => appBloc.add(any())).thenReturn(null);
    when(() => commonBloc.add(any())).thenAnswer((invocation) {
      final event = invocation.positionalArguments.first;
      if (event is ExceptionEmitted) {
        event.appExceptionWrapper.exceptionCompleter?.complete();
      }
    });
    when(() => navigator.getCurrentRouteNames()).thenReturn(const <String?>[]);
    when(
      () => getAiChatHistoryUseCase.execute(any()),
    ).thenAnswer((_) async => const GetAiChatHistoryOutput());
    when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
      (_) => Stream<SendAiChatMessageOutput>.fromIterable([
        const SendAiChatMessageOutput(event: AiChatStreamEvent.completed(result: sendResult)),
      ]),
    );
  });

  blocTest<AiChatBloc, AiChatState>(
    'reverses newest-first history into chronological messages',
    setUp: () {
      when(() => getAiChatHistoryUseCase.execute(any())).thenAnswer(
        (_) async => const GetAiChatHistoryOutput(messages: [olderAssistant, olderUser]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatViewInitiated()),
    expect:
        () => const [
          AiChatState(messages: [olderUser, olderAssistant], historyLoadedCount: 2),
        ],
  );

  blocTest<AiChatBloc, AiChatState>(
    'appends a placeholder then the assistant reply when sending succeeds',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: '  How much?  ')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
        ],
    verify: (_) {
      verify(
        () => sendAiChatMessageUseCase.execute(
          any(
            that: isA<SendAiChatMessageInput>().having(
              (input) => input.message,
              'message',
              'How much?',
            ),
          ),
        ),
      ).called(1);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'does not advance historyLoadedCount on done',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
        (_) => Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(
            event: AiChatStreamEvent.completed(
              result: AiChatSendResult(userMessageId: 101, message: persistedAssistantReply),
            ),
          ),
        ]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
        ],
  );

  blocTest<AiChatBloc, AiChatState>(
    'copies persisted ids onto the last turn and advances historyLoadedCount by one turn',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
        (_) => Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(event: AiChatStreamEvent.completed(result: sendResult)),
          const SendAiChatMessageOutput(
            event: AiChatStreamEvent.persisted(userMessageId: 101, assistantMessageId: 102),
          ),
        ]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
          AiChatState(
            messages: [AiChatMessage(id: 101, content: 'How much?'), persistedAssistantReply],
            historyLoadedCount: 2,
          ),
        ],
    verify: (bloc) {
      expect(bloc.state.streamingPhase, AiChatStreamingPhase.idle);
      expect(bloc.state.historyLoadedCount, 2);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'moves to loadingContext before the first delta and returns to idle on done',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
        (_) => Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(
            event: AiChatStreamEvent.status(status: AiChatSseConstants.statusLoadingContext),
          ),
          const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You spent 50.')),
          const SendAiChatMessageOutput(event: AiChatStreamEvent.completed(result: sendResult)),
        ]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.loadingContext,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You spent 50.'),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
        ],
  );

  blocTest<AiChatBloc, AiChatState>(
    'returns to idle and keeps the user plus partial assistant text when stopped after loadingContext',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer((invocation) {
        final input = invocation.positionalArguments.first as SendAiChatMessageInput;
        final controller = StreamController<SendAiChatMessageOutput>();
        input.cancelToken?.whenCancel(() {
          if (!controller.isClosed) {
            controller
              ..addError(const RemoteException(kind: RemoteExceptionKind.cancellation))
              ..close();
          }
        });
        scheduleMicrotask(() {
          if (!controller.isClosed) {
            controller.add(
              const SendAiChatMessageOutput(
                event: AiChatStreamEvent.status(status: AiChatSseConstants.statusLoadingContext),
              ),
            );
            controller.add(
              const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You ')),
            );
          }
        });
        return controller.stream;
      });
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AiChatMessageSubmitted(message: 'How much?'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AiChatGenerationStopRequested());
    },
    wait: const Duration(milliseconds: 20),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.loadingContext,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
          AiChatState(
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
        ],
    verify: (bloc) {
      expect(bloc.state.streamingPhase, AiChatStreamingPhase.idle);
      expect(bloc.state.messages, [
        const AiChatMessage(content: 'How much?'),
        const AiChatMessage(role: AiChatRole.assistant, content: 'You '),
      ]);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'streams assistant deltas into the placeholder bubble',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer((_) async* {
        yield const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You '));
        await Future<void>.delayed(DurationConstants.aiChatStreamUiThrottle);
        yield const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'spent 50.'));
        yield const SendAiChatMessageOutput(event: AiChatStreamEvent.completed(result: sendResult));
      });
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    wait: DurationConstants.aiChatStreamUiThrottle + const Duration(milliseconds: 20),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You spent 50.'),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
        ],
  );

  blocTest<AiChatBloc, AiChatState>(
    'keeps throttled trailing deltas when completed arrives',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
        (_) => Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You ')),
          const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'spent 50.')),
          const SendAiChatMessageOutput(event: AiChatStreamEvent.completed(result: sendResult)),
        ]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    verify: (bloc) {
      expect(bloc.state.isSending, isFalse);
      expect(bloc.state.streamingPhase, AiChatStreamingPhase.idle);
      expect(bloc.state.messages, [const AiChatMessage(content: 'How much?'), assistantReply]);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'does not overwrite streamed assistant text with a different done reply',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer(
        (_) => Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You spent 50.')),
          const SendAiChatMessageOutput(
            event: AiChatStreamEvent.completed(
              result: AiChatSendResult(
                message: AiChatMessage(role: AiChatRole.assistant, content: 'TOTAL OVERRIDE'),
              ),
            ),
          ),
        ]),
      );
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You spent 50.'),
            ],
          ),
          AiChatState(messages: [AiChatMessage(content: 'How much?'), assistantReply]),
        ],
  );

  blocTest<AiChatBloc, AiChatState>(
    'keeps the user message and removes the empty assistant bubble when sending fails before deltas',
    setUp: () {
      when(
        () => sendAiChatMessageUseCase.execute(any()),
      ).thenThrow(const RemoteException(kind: RemoteExceptionKind.network));
    },
    build: buildBloc,
    seed: () => const AiChatState(messages: [olderUser]),
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'Again')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              olderUser,
              AiChatMessage(content: 'Again'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(messages: [olderUser, AiChatMessage(content: 'Again')]),
        ],
    verify: (_) {
      verify(
        () => commonBloc.add(
          any(
            that: isA<ExceptionEmitted>().having(
              (event) => event.appExceptionWrapper.doOnRetry,
              'doOnRetry',
              isNull,
            ),
          ),
        ),
      ).called(1);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'keeps streamed assistant text when sending fails after a delta',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer((_) {
        return Stream<SendAiChatMessageOutput>.fromIterable([
          const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You ')),
        ]).asyncExpand((output) async* {
          yield output;
          throw const RemoteException(kind: RemoteExceptionKind.network);
        });
      });
    },
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: 'How much?')),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
          AiChatState(
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
        ],
    verify: (bloc) {
      expect(bloc.state.streamingPhase, AiChatStreamingPhase.idle);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'cancels the in-flight token and keeps the user message plus streamed assistant text',
    setUp: () {
      when(() => sendAiChatMessageUseCase.execute(any())).thenAnswer((invocation) {
        final input = invocation.positionalArguments.first as SendAiChatMessageInput;
        final controller = StreamController<SendAiChatMessageOutput>();
        input.cancelToken?.whenCancel(() {
          if (!controller.isClosed) {
            controller
              ..addError(const RemoteException(kind: RemoteExceptionKind.cancellation))
              ..close();
          }
        });
        scheduleMicrotask(() {
          if (!controller.isClosed) {
            controller.add(
              const SendAiChatMessageOutput(event: AiChatStreamEvent.delta(content: 'You ')),
            );
          }
        });
        return controller.stream;
      });
    },
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AiChatMessageSubmitted(message: 'How much?'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      bloc.add(const AiChatGenerationStopRequested());
    },
    wait: const Duration(milliseconds: 20),
    expect:
        () => const [
          AiChatState(
            isSending: true,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant),
            ],
          ),
          AiChatState(
            isSending: true,
            streamingPhase: AiChatStreamingPhase.generating,
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
          AiChatState(
            messages: [
              AiChatMessage(content: 'How much?'),
              AiChatMessage(role: AiChatRole.assistant, content: 'You '),
            ],
          ),
        ],
    verify: (bloc) {
      final captured =
          verify(() => sendAiChatMessageUseCase.execute(captureAny())).captured.single
              as SendAiChatMessageInput;
      expect(captured.cancelToken?.isCancelled, isTrue);
      expect(bloc.state.streamingPhase, AiChatStreamingPhase.idle);
      verifyNever(() => commonBloc.add(any(that: isA<ExceptionEmitted>())));
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'ignores blank messages',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: '   ')),
    expect: () => const <AiChatState>[],
    verify: (_) {
      verifyNever(() => sendAiChatMessageUseCase.execute(any()));
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'prepends the next history page and advances the paging offset',
    setUp: () {
      when(() => getAiChatHistoryUseCase.execute(any())).thenAnswer(
        (_) async => const GetAiChatHistoryOutput(messages: [oldestAssistant, oldestUser]),
      );
    },
    seed:
        () => const AiChatState(
          messages: [olderUser, olderAssistant],
          historyLoadedCount: 20,
          hasMore: true,
        ),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatLoadMoreRequested()),
    expect:
        () => const [
          AiChatState(
            messages: [olderUser, olderAssistant],
            historyLoadedCount: 20,
            hasMore: true,
            isLoadingMore: true,
          ),
          AiChatState(
            messages: [oldestUser, oldestAssistant, olderUser, olderAssistant],
            historyLoadedCount: 22,
          ),
        ],
    verify: (_) {
      verify(
        () => getAiChatHistoryUseCase.execute(const GetAiChatHistoryInput(offset: 20)),
      ).called(1);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'does not load more when hasMore is false',
    seed: () => const AiChatState(messages: [olderUser], historyLoadedCount: 1),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatLoadMoreRequested()),
    expect: () => const <AiChatState>[],
    verify: (_) {
      verifyNever(() => getAiChatHistoryUseCase.execute(any()));
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'clears isLoadingMore when history paging fails',
    setUp: () {
      when(
        () => getAiChatHistoryUseCase.execute(any()),
      ).thenThrow(const RemoteException(kind: RemoteExceptionKind.network));
    },
    seed: () => const AiChatState(messages: [olderUser], historyLoadedCount: 20, hasMore: true),
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatLoadMoreRequested()),
    expect:
        () => const [
          AiChatState(
            messages: [olderUser],
            historyLoadedCount: 20,
            hasMore: true,
            isLoadingMore: true,
          ),
          AiChatState(messages: [olderUser], historyLoadedCount: 20, hasMore: true),
        ],
  );
}
