import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_code_response.freezed.dart';
part 'status_code_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class StatusCodeResponse<T> with _$StatusCodeResponse<T> {
  const factory StatusCodeResponse({int? statusCode, T? data}) = _StatusCodeResponse;

  factory StatusCodeResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$StatusCodeResponseFromJson(json, fromJsonT);
}
