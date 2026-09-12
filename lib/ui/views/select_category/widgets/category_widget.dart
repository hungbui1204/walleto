import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({super.key, required this.category, this.onCategorySelected});

  final Category category;
  final void Function(Category)? onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Dimens.d20.responsive()),
      child: CommonListRow(
        leading: CommonCircleNetworkImage(imageUrl: category.iconUrl),
        title: Text(category.name, style: AppTextStyles.s14wNormalBlack()),
        onTap:
            onCategorySelected == null
                ? null
                : () {
                  onCategorySelected!.call(category);
                  context.read<AppNavigator>().pop(useRootNavigator: true);
                },
      ),
    );
  }
}
