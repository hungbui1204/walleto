import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
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
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * 0.7),
          margin: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.d16.responsive(),
            vertical: Dimens.d20.responsive(),
          ),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(Dimens.d16.responsive()),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.current.selectIcon, style: AppTextStyles.s20wNormalBlack()),
                SizedBox(height: Dimens.d20.responsive()),
                BlocBuilder<SelectIconBloc, SelectIconState>(
                  buildWhen: (previous, current) => previous.icons != current.icons,
                  builder: (context, state) {
                    return GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: Dimens.d30.responsive(),
                        crossAxisSpacing: Dimens.d30.responsive(),
                      ),
                      itemCount: state.icons.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            widget.onIconSelected?.call(state.icons[index].url!);
                            navigator.pop(useRootNavigator: true);
                          },
                          child: CommonCircleNetworkImage(imageUrl: state.icons[index].url),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
