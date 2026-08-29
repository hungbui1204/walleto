import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends BasePageState<LoginView, LoginBloc>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _otpController;
  late final TextEditingController _emailSignUpController;
  late final TextEditingController _passwordSignUpController;
  late final TextEditingController _confirmPasswordSignUpController;
  late final TabController _tabController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _otpController = TextEditingController();
    _emailSignUpController = TextEditingController();
    _passwordSignUpController = TextEditingController();
    _confirmPasswordSignUpController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    _otpController.dispose();
    _emailSignUpController.dispose();
    _passwordSignUpController.dispose();
    _confirmPasswordSignUpController.dispose();
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: NoirScaffoldBody(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Dimens.d24.responsive(),
                    Dimens.d36.responsive(),
                    Dimens.d24.responsive(),
                    Dimens.d8.responsive(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WALLETO',
                        style: AppThemes.display(
                          fontSize: Dimens.d12.responsive(),
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          letterSpacing: 3,
                        ),
                      ),
                      SizedBox(height: Dimens.d20.responsive()),
                      Text(
                        S.current.welcomeToApp,
                        style: AppThemes.display(
                          fontSize: Dimens.d32.responsive(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: Dimens.d12.responsive()),
                      const AccentRule(),
                    ],
                  ),
                ),
                SizedBox(height: Dimens.d16.responsive()),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d24.responsive(),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.d12.responsive(),
                        ),
                        child: Text(S.current.login),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimens.d12.responsive(),
                        ),
                        child: Text(S.current.signUp),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      LoginTab(
                        emailController: _emailController,
                        passwordController: _passwordController,
                      ),
                      SignUpTab(
                        emailSignUpController: _emailSignUpController,
                        passwordSignUpController: _passwordSignUpController,
                        confirmPasswordSignUpController:
                            _confirmPasswordSignUpController,
                        otpSignUpController: _otpController,
                        tabController: _tabController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
