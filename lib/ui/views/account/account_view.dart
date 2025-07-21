import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends BasePageState<AccountView, AccountBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: S.current.account),
      body: Center(
        child: CommonButton(
          text: 'logout',
          onTap: () => context.read<AppBloc>().add(const SignOutButtonPressed()),
        ),
      ),
    );
  }
}
