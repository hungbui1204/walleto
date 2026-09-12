import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class HomeLoadingSkeletonWidget extends StatelessWidget {
  const HomeLoadingSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Dimens.d8.responsive()),
            Align(
              alignment: Alignment.centerLeft,
              child: CommonShimmerBox(
                height: Dimens.d12.responsive(),
                width: Dimens.d80.responsive(),
              ),
            ),
            SizedBox(height: Dimens.d12.responsive()),
            CommonShimmerBox(height: Dimens.d40.responsive()),
            SizedBox(height: Dimens.d16.responsive()),
            Row(
              children: [
                Expanded(child: CommonShimmerBox(height: Dimens.d72.responsive())),
                SizedBox(width: Dimens.d12.responsive()),
                Expanded(child: CommonShimmerBox(height: Dimens.d72.responsive())),
              ],
            ),
            SizedBox(height: Dimens.d16.responsive()),
            const CommonShimmerPanel(
              child: Column(
                children: [
                  CommonShimmerListTile(lineCount: 1),
                  CommonShimmerListTile(lineCount: 1),
                  CommonShimmerListTile(lineCount: 1),
                ],
              ),
            ),
            SizedBox(height: Dimens.d16.responsive()),
            CommonShimmerPanel(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: CommonShimmerBox(height: Dimens.d32.responsive())),
                      SizedBox(width: Dimens.d8.responsive()),
                      Expanded(child: CommonShimmerBox(height: Dimens.d32.responsive())),
                    ],
                  ),
                  SizedBox(height: Dimens.d16.responsive()),
                  CommonShimmerBox(height: Dimens.d330.responsive()),
                ],
              ),
            ),
            SizedBox(height: Dimens.d16.responsive()),
            const CommonShimmerPanel(
              child: Column(
                children: [
                  CommonShimmerListTile(),
                  CommonShimmerListTile(),
                  CommonShimmerListTile(),
                ],
              ),
            ),
            SizedBox(height: Dimens.d28.responsive()),
          ],
        ),
      ),
    );
  }
}
