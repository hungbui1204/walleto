import 'package:flutter/material.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SelectCategoryPopup extends StatefulWidget {
  const SelectCategoryPopup({super.key, required this.onCategorySelected});

  final void Function(Category) onCategorySelected;

  @override
  State<SelectCategoryPopup> createState() => _SelectCategoryPopupState();
}

class _SelectCategoryPopupState extends BasePageState<SelectCategoryPopup, SelectCategoryBloc> {
  @override
  void initState() {
    bloc.add(const SelectCategoryViewInitiated());
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
      ),
      child: Column(children: []),
    );
  }
}

class _CategoryTreeWidget extends StatelessWidget {
  const _CategoryTreeWidget();

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
