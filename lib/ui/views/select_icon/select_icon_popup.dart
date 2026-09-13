import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class SelectIconPopup extends StatefulWidget {
  const SelectIconPopup({super.key, required this.iconType, this.onIconSelected});

  final IconType iconType;
  final void Function(String)? onIconSelected;

  @override
  State<SelectIconPopup> createState() => _SelectIconPopupState();
}

class _SelectIconPopupState extends BasePageState<SelectIconPopup, SelectIconBloc> {
  @override
  void initState() {
    bloc.add(SelectIconViewInitialized(iconType: widget.iconType));
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonPickerSheet(
      title: S.current.selectIcon,
      expandChild: true,
      child: BlocBuilder<SelectIconBloc, SelectIconState>(
        buildWhen: (previous, current) => previous.icons != current.icons,
        builder: (context, state) {
          return GridView.builder(
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: Dimens.d30.responsive(),
              crossAxisSpacing: Dimens.d30.responsive(),
            ),
            itemCount: state.icons.length,
            itemBuilder: (context, index) {
              return Pressable(
                onTap: () {
                  widget.onIconSelected?.call(state.icons[index].url!);
                  navigator.pop(useRootNavigator: true);
                },
                borderRadius: BorderRadius.circular(Dimens.d36.responsive()),
                child: CommonCircleNetworkImage(imageUrl: state.icons[index].url),
              );
            },
          );
        },
      ),
    );
  }
}
