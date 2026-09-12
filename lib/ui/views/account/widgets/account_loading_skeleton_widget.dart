import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class AccountLoadingSkeletonWidget extends StatelessWidget {
  const AccountLoadingSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonShimmer(
      child: Padding(
        padding: EdgeInsets.only(top: Dimens.d30.responsive()),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
              child: Column(
                children: [
                  SizedBox(height: Dimens.d40.responsive()),
                  CommonShimmerPanel(
                    showTitleBar: false,
                    child: Column(
                      children: [
                        SizedBox(height: Dimens.d40.responsive()),
                        Center(
                          child: CommonShimmerBox(
                            height: Dimens.d16.responsive(),
                            width: Dimens.d160.responsive(),
                          ),
                        ),
                        SizedBox(height: Dimens.d8.responsive()),
                        Center(
                          child: CommonShimmerBox(
                            height: Dimens.d14.responsive(),
                            width: Dimens.d200.responsive(),
                          ),
                        ),
                        SizedBox(height: Dimens.d10.responsive()),
                        const CommonShimmerListTile(lineCount: 1),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimens.d20.responsive()),
                  const CommonShimmerPanel(
                    showTitleBar: false,
                    child: Column(
                      children: [
                        CommonShimmerListTile(lineCount: 1),
                        CommonShimmerListTile(lineCount: 1),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimens.d20.responsive()),
                  const CommonShimmerPanel(
                    showTitleBar: false,
                    child: Column(
                      children: [
                        CommonShimmerListTile(lineCount: 1),
                        CommonShimmerListTile(lineCount: 1),
                        CommonShimmerListTile(lineCount: 1),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimens.d20.responsive()),
                  CommonShimmerBox(height: Dimens.d48.responsive()),
                ],
              ),
            ),
            CommonShimmerCircle(size: Dimens.d80.responsive()),
          ],
        ),
      ),
    );
  }
}
