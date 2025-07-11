import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
sealed class Category with _$Category {
  const factory Category({
    @Default(0) int id,
    @Default('') String name,
    String? userId,
    @Default('') String iconUrl,
    @Default(false) bool isParent,
    int? parentId,
    @Default(<Category>[]) List<Category> children,
  }) = _Category;
}
