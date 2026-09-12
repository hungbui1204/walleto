import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

class TransactionsLoadingSkeletonWidget extends StatelessWidget {
  const TransactionsLoadingSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimens.d12.responsive()),
            Center(
              child: CommonShimmerBox(
                width: Dimens.d160.responsive(),
                height: Dimens.d44.responsive(),
              ),
            ),
            SizedBox(height: Dimens.d20.responsive()),
            CommonShimmerPanel(
              showTitleBar: false,
              child: CommonShimmerBox(height: Dimens.d44.responsive()),
            ),
            SizedBox(height: Dimens.d20.responsive()),
            const _TransactionsDaySkeletonPanel(tileCount: 4),
            SizedBox(height: Dimens.d20.responsive()),
            const _TransactionsDaySkeletonPanel(tileCount: 3),
            SizedBox(height: Dimens.d24.responsive()),
          ],
        ),
      ),
    );
  }
}

class _TransactionsDaySkeletonPanel extends StatelessWidget {
  const _TransactionsDaySkeletonPanel({required this.tileCount});

  final int tileCount;

  @override
  Widget build(BuildContext context) {
    return CommonShimmerPanel(
      title: Row(
        children: [
          CommonShimmerBox(width: Dimens.d32.responsive(), height: Dimens.d28.responsive()),
          SizedBox(width: Dimens.d10.responsive()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonShimmerBox(width: Dimens.d80.responsive(), height: Dimens.d12.responsive()),
              SizedBox(height: Dimens.d4.responsive()),
              CommonShimmerBox(width: Dimens.d64.responsive(), height: Dimens.d12.responsive()),
            ],
          ),
          const Spacer(),
          CommonShimmerBox(width: Dimens.d56.responsive(), height: Dimens.d14.responsive()),
        ],
      ),
      child: Column(
        children: List<Widget>.generate(tileCount, (_) {
          return const CommonShimmerListTile(lineCount: 1);
        }),
      ),
    );
  }
}
