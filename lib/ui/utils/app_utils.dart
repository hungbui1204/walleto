import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';

class AppUtils {
  const AppUtils._();

  static bool isEndWithOperator(String input) {
    return OperationType.values.map((e) => e.symbol).toList().any((element) {
      return element.equalsIgnoreCase(input[input.length - 1]);
    });
  }

  static bool isContainOperator(String input) {
    return OperationType.values.map((e) => e.symbol).toList().any((element) {
      return input.contains(element);
    });
  }

  static String mapWeekDayToString(int weekDay) {
    return switch (weekDay) {
      DateTime.monday => S.current.monday,
      DateTime.tuesday => S.current.tuesday,
      DateTime.wednesday => S.current.wednesday,
      DateTime.thursday => S.current.thursday,
      DateTime.friday => S.current.friday,
      DateTime.saturday => S.current.saturday,
      DateTime.sunday => S.current.sunday,
      _ => '',
    };
  }

  static String mapMonthToString(int month) {
    return switch (month) {
      DateTime.january => S.current.january,
      DateTime.february => S.current.february,
      DateTime.march => S.current.march,
      DateTime.april => S.current.april,
      DateTime.may => S.current.may,
      DateTime.june => S.current.june,
      DateTime.july => S.current.july,
      DateTime.august => S.current.august,
      DateTime.september => S.current.september,
      DateTime.october => S.current.october,
      DateTime.november => S.current.november,
      DateTime.december => S.current.december,
      _ => '',
    };
  }

  /// Builds a tree structure of categories from a flat list of categories.
  static List<Category> buildCategoryTree(List<Category> allCategories) {
    final Map<String, Category> categoryMap = {
      for (var category in allCategories) '${category.id}': category,
    };

    for (var category in allCategories) {
      if (category.isParent) {
      } else if (category.parentId != null && categoryMap.containsKey('${category.parentId}')) {
        final parent = categoryMap['${category.parentId}']!;
        categoryMap['${category.parentId}'] = parent.copyWith(
          children: [...parent.children, category],
        );
      }
    }

    return categoryMap.values.where((category) => category.isParent).toList();
  }
}
