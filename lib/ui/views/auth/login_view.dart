import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final TabController _tabController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                        _LoginTab(
                          emailController: _emailController,
                          passwordController: _passwordController,
                        ),
                        const _SignUpTab(),
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

class _LoginTab extends StatelessWidget {
  const _LoginTab({required this.emailController, required this.passwordController});

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: Dimens.d30.responsive()),
          _EmailForm(emailController: emailController),
          SizedBox(height: Dimens.d20.responsive()),
          _PasswordForm(passwordController: passwordController),
          SizedBox(height: Dimens.d40.responsive()),
          BlocBuilder<LoginBloc, LoginState>(
            buildWhen: (previous, current) {
              return previous.isEnableLoginButton != current.isEnableLoginButton;
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: CommonButton(
                  text: S.current.login,
                  onTap:
                      state.isEnableLoginButton
                          ? () {
                            ViewUtils.hideKeyboard(context);
                            context.read<LoginBloc>().add(const SignInButtonPressed());
                          }
                          : null,
                ),
              );
            },
          ),
          SizedBox(height: Dimens.d20.responsive()),
          Text(S.current.or, style: AppTextStyles.s14wNormalBlack()),
          SizedBox(height: Dimens.d20.responsive()),
          SizedBox(
            width: double.infinity,
            child: CommonButton(
              text: S.current.continueWithGoogle,
              backgroundColor: secondaryColor,
              icon: Assets.icons.google.svg(
                height: Dimens.d30.responsive(),
                width: Dimens.d30.responsive(),
              ),
              onTap: () {
                ViewUtils.hideKeyboard(context);
                //TODO: Implement Google Sign-In
              },
            ),
          ),
          SizedBox(height: Dimens.d10.responsive()),
          SizedBox(
            width: double.infinity,
            child: CommonButton(
              text: S.current.continueWithFacebook,
              icon: Assets.icons.facebook.svg(
                height: Dimens.d30.responsive(),
                width: Dimens.d30.responsive(),
              ),
              onTap: () {
                ViewUtils.hideKeyboard(context);
                //TODO: Implement Facebook Sign-In
              },
            ),
          ),
          SizedBox(height: Dimens.d30.responsive()),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: S.current.youWillAcceptOur,
              style: AppTextStyles.s12wNormalBlack(),
              children: [
                TextSpan(text: S.current.space, style: AppTextStyles.s12wNormalBlack()),
                TextSpan(
                  text: S.current.termsAndConditions,
                  style: AppTextStyles.s12wNormalBlackUnderline(),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Navigate to Terms and Conditions page
                        },
                ),
                TextSpan(text: S.current.dot, style: AppTextStyles.s12wNormalBlack()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpTab extends StatelessWidget {
  const _SignUpTab();

  @override
  Widget build(BuildContext context) {
    return const Column();
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.email != current.email || previous.emailError != current.emailError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  prefixIcon: Assets.icons.accountActive.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  hintText: S.current.hintEmail,
                  controller: emailController,
                  onChanged: (email) {
                    context.read<LoginBloc>().add(LoginEmailInputChanged(email: email));
                  },
                ),
                if (state.emailError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.emailError, style: AppTextStyles.s14wNormalAlert()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PasswordForm extends StatelessWidget {
  const _PasswordForm({required this.passwordController});

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<LoginBloc, LoginState>(
          buildWhen: (previous, current) {
            return previous.password != current.password ||
                previous.passwordError != current.passwordError;
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextField(
                  prefixIcon: Assets.icons.locker.svg(
                    width: Dimens.d24.responsive(),
                    height: Dimens.d24.responsive(),
                  ),
                  hintText: S.current.hintPassword,
                  onChanged: (password) {
                    context.read<LoginBloc>().add(LoginPasswordInputChanged(password: password));
                  },
                  controller: passwordController,
                  isPasswordField: true,
                ),
                if (state.passwordError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: Dimens.d8.responsive()),
                    child: Text(state.passwordError, style: AppTextStyles.s14wNormalAlert()),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
