import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';

part 'send_ai_chat_message_use_case.freezed.dart';

@injectable
class SendAiChatMessageUseCase
    extends BaseFutureUseCase<SendAiChatMessageInput, SendAiChatMessageOutput> {
  const SendAiChatMessageUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<SendAiChatMessageOutput> buildUseCase(SendAiChatMessageInput input) async {
    final response = await _repository.sendAiChatMessage(message: input.message);

    return SendAiChatMessageOutput(message: response);
  }
}

@freezed
sealed class SendAiChatMessageInput extends BaseInput with _$SendAiChatMessageInput {
  const SendAiChatMessageInput._();

  const factory SendAiChatMessageInput({required String message}) = _SendAiChatMessageInput;
}

@freezed
sealed class SendAiChatMessageOutput extends BaseOutput with _$SendAiChatMessageOutput {
  const SendAiChatMessageOutput._();

  const factory SendAiChatMessageOutput({required AiChatMessage message}) =
      _SendAiChatMessageOutput;
}
