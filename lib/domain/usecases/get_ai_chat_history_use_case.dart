import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'get_ai_chat_history_use_case.freezed.dart';

@injectable
class GetAiChatHistoryUseCase
    extends BaseFutureUseCase<GetAiChatHistoryInput, GetAiChatHistoryOutput> {
  const GetAiChatHistoryUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<GetAiChatHistoryOutput> buildUseCase(GetAiChatHistoryInput input) async {
    final response = await _repository.getAiChatHistory(
      offset: input.offset,
      limit: input.limit,
    );

    return GetAiChatHistoryOutput(messages: response);
  }
}

@freezed
sealed class GetAiChatHistoryInput extends BaseInput with _$GetAiChatHistoryInput {
  const GetAiChatHistoryInput._();

  const factory GetAiChatHistoryInput({
    @Default(0) int offset,
    @Default(20) int limit,
  }) = _GetAiChatHistoryInput;
}

@freezed
sealed class GetAiChatHistoryOutput extends BaseOutput with _$GetAiChatHistoryOutput {
  const GetAiChatHistoryOutput._();

  const factory GetAiChatHistoryOutput({
    @Default(<AiChatHistoryMessage>[]) List<AiChatHistoryMessage> messages,
  }) = _GetAiChatHistoryOutput;
}
