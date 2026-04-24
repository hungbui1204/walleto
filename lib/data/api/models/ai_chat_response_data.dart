import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/data/data.dart';

part 'ai_chat_response_data.freezed.dart';
part 'ai_chat_response_data.g.dart';

@freezed
sealed class AiChatResponseData with _$AiChatResponseData {
  const factory AiChatResponseData({
    @JsonKey(name: 'reply') String? reply,
    @JsonKey(name: 'model') String? model,
    @JsonKey(name: 'usage') AiChatUsageData? usage,
  }) = _AiChatResponseData;

  factory AiChatResponseData.fromJson(Map<String, dynamic> json) =>
      _$AiChatResponseDataFromJson(json);
}
