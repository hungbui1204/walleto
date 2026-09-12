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
    when(
      () => sendAiChatMessageUseCase.execute(any()),
    ).thenAnswer((_) async => const SendAiChatMessageOutput(result: sendResult));
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
    'appends the user bubble then the assistant reply when sending succeeds',
    build: buildBloc,
    act: (bloc) => bloc.add(const AiChatMessageSubmitted(message: '  How much?  ')),
    expect:
        () => const [
          AiChatState(isSending: true, messages: [AiChatMessage(content: 'How much?')]),
          AiChatState(
            messages: [AiChatMessage(content: 'How much?'), assistantReply],
            historyLoadedCount: 2,
          ),
        ],
    verify: (_) {
      verify(
        () => sendAiChatMessageUseCase.execute(const SendAiChatMessageInput(message: 'How much?')),
      ).called(1);
    },
  );

  blocTest<AiChatBloc, AiChatState>(
    'restores messages and does not keep an assistant bubble when sending fails',
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
          AiChatState(isSending: true, messages: [olderUser, AiChatMessage(content: 'Again')]),
          AiChatState(messages: [olderUser]),
        ],
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
