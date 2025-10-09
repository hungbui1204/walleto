import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CategoryTreeWidget extends StatelessWidget {
  const CategoryTreeWidget({
    super.key,
    required this.parentCategory,
    required this.onCategorySelected,
    required this.onParentCategorySelected,
  });

  final Category parentCategory;
  final void Function(Category) onCategorySelected;
  final void Function(Category) onParentCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimens.d10.responsive()),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        border: Border.all(),
      ),
      child: Column(
        children: [
          ParentCategoryWidget(
            category: parentCategory,
            onCategorySelected: onParentCategorySelected,
          ),
          if (parentCategory.children.isNotEmpty) ...[
            SizedBox(height: Dimens.d20.responsive()),
            ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: parentCategory.children.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return CategoryWidget(
                  category: parentCategory.children[index],
                  onCategorySelected: onCategorySelected,
                );
              },
              separatorBuilder: (context, index) {
                return CommonLine(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
