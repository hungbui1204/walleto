import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:walleto/domain/domain.dart';

part 'paged_list.freezed.dart';

@freezed
sealed class PagedList<T> with _$PagedList<T> {
  const PagedList._();

  const factory PagedList({
    required List<T> data,
    @Default(null) Object? otherData,
    String? key,
  }) = _PagedList;

  bool get isLastPage => key.isNullOrEmpty;

  LoadMoreOutput<T> toLoadMoreOutput() {
    return LoadMoreOutput(data: data, isLastPage: isLastPage);
  }
}
