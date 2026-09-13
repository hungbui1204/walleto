import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class ParentCategoryWidget extends StatelessWidget {
  const ParentCategoryWidget({super.key, required this.category, this.onCategorySelected});

  final Category category;
  final void Function(Category)? onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return CommonListRow(
      leading: CommonCircleNetworkImage(
        imageUrl: category.iconUrl,
        size: Dimens.d38.responsive(),
        backgroundColor: primaryShadeColor,
      ),
      title: Text(category.name, style: AppTextStyles.s18wNormalBlack()),
      onTap:
          onCategorySelected == null
              ? null
              : () {
                onCategorySelected!.call(category);
                context.read<AppNavigator>().pop(useRootNavigator: true);
              },
    );
  }
}
