import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_response.freezed.dart';
part 'list_response.g.dart';

@Freezed(genericArgumentFactories: true)
sealed class ListResponse<T> with _$ListResponse<T> {
  const factory ListResponse({
    @JsonKey(name: 'list') List<T>? list,
  }) = _ListResponse;

  factory ListResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$ListResponseFromJson(json, fromJsonT);
}
