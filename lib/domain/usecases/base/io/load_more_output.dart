import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/shared/shared.dart';

part 'load_more_output.freezed.dart';

@freezed
sealed class LoadMoreOutput<T> extends BaseOutput with _$LoadMoreOutput<T> {
  const LoadMoreOutput._();

  const factory LoadMoreOutput({
    required List<T> data,
    @Default(null) Object? otherData,
    String? key,
    @Default(PagingConstants.initialPage) int page,
    @Default(0) int offset,
    @Default(false) bool isLastPage,
    @Default(false) bool isRefreshSuccess,
  }) = _LoadMoreOutput;
}
