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
    super.dispose();
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: primaryShade1Color,
          toolbarHeight: Dimens.d220.responsive(),
          title: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Assets.images.payment.svg(
                  width: Dimens.d220.responsive(),
                  height: Dimens.d220.responsive(),
                  fit: BoxFit.cover,
                ),
              ),
              Text(S.current.welcomeToApp, style: AppTextStyles.s28wBoldBlack()),
            ],
          ),
        ),
        body: Stack(
          children: [
            CustomPaint(
              size: Size(context.mediaQuery.size.width, context.mediaQuery.size.width / 2),
              painter: HalfCirclePainter(),
            ),
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  tabs: [
                    Padding(
                      padding: EdgeInsets.all(Dimens.d12.responsive()),
                      child: Text(
                        S.current.login,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.d16.responsive(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Dimens.d12.responsive()),
                      child: Text(
                        S.current.signUp,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.d16.responsive(),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
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
                          confirmPasswordSignUpController: _confirmPasswordSignUpController,
                          otpSignUpController: _otpController,
                          tabController: _tabController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
