import 'package:flutter/material.dart';
import 'package:walleto/di/di.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ParentCategoryWidget extends StatelessWidget {
  const ParentCategoryWidget({super.key, required this.category, required this.onCategorySelected});

  final Category category;
  final void Function(Category) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: transParentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
        onTap: () {
          onCategorySelected.call(category);
          getIt.get<AppNavigator>().pop(useRootNavigator: true);
        },
        child: Row(
          children: [
            CommonCircleNetworkImage(
              imageUrl: category.iconUrl,
              size: Dimens.d38.responsive(),
              backgroundColor: secondaryColor,
            ),
            SizedBox(width: Dimens.d20.responsive()),
            Text(category.name, style: AppTextStyles.s18wNormalBlack()),
          ],
        ),
      ),
    );
  }
}
