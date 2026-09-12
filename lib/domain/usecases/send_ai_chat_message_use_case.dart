import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'send_ai_chat_message_use_case.freezed.dart';

@injectable
class SendAiChatMessageUseCase
    extends BaseStreamUseCase<SendAiChatMessageInput, SendAiChatMessageOutput> {
  const SendAiChatMessageUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Stream<SendAiChatMessageOutput> buildUseCase(SendAiChatMessageInput input) {
    return _repository
        .sendAiChatMessage(message: input.message, cancelToken: input.cancelToken)
        .map((event) => SendAiChatMessageOutput(event: event));
  }
}

@freezed
sealed class SendAiChatMessageInput extends BaseInput with _$SendAiChatMessageInput {
  const SendAiChatMessageInput._();

  const factory SendAiChatMessageInput({required String message, AppCancelToken? cancelToken}) =
      _SendAiChatMessageInput;
}

@freezed
sealed class SendAiChatMessageOutput extends BaseOutput with _$SendAiChatMessageOutput {
  const SendAiChatMessageOutput._();

  const factory SendAiChatMessageOutput({required AiChatStreamEvent event}) =
      _SendAiChatMessageOutput;
}
