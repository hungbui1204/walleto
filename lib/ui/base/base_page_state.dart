import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

abstract class BasePageState<T extends StatefulWidget, B extends BaseBloc>
    extends BasePageStateDelegate<T, B>
    with LogMixin {}

abstract class BasePageStateDelegate<T extends StatefulWidget, B extends BaseBloc> extends State<T>
    implements ExceptionHandlerListener {
  late final navigator = GetIt.instance.get<AppNavigator>();
  late final appBloc = GetIt.instance.get<AppBloc>();
  late final exceptionMessageMapper = const ExceptionMessageMapper();
  late final exceptionHandler = ExceptionHandler(navigator: navigator, listener: this);

  late final commonBloc =
      GetIt.instance.get<CommonBloc>()
        ..navigator = navigator
        ..disposeBag = disposeBag
        ..appBloc = appBloc
        ..exceptionHandler = exceptionHandler
        ..exceptionMessageMapper = exceptionMessageMapper;

  late final bloc =
      GetIt.instance.get<B>()
        ..navigator = navigator
        ..disposeBag = disposeBag
        ..appBloc = appBloc
        ..commonBloc = commonBloc
        ..exceptionHandler = exceptionHandler
        ..exceptionMessageMapper = exceptionMessageMapper;

  late final disposeBag = DisposeBag();

  bool get isAppWidget => false;

  @override
  void dispose() {
    super.dispose();
    disposeBag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isAppWidget) {
      AppDimen.of(context);
    }

    return RepositoryProvider(
      create: (context) => navigator,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: appBloc),
          BlocProvider(create: (_) => bloc),
          BlocProvider(create: (_) => commonBloc),
        ],
        child: BlocListener<CommonBloc, CommonState>(
          listenWhen: (previous, current) {
            return previous.appExceptionWrapper != current.appExceptionWrapper &&
                current.appExceptionWrapper != null;
          },
          listener: (context, state) => handleException(state.appExceptionWrapper!),
          child: buildPageListeners(
            child:
                isAppWidget
                    ? buildPage(context)
                    : Stack(
                      children: [
                        buildPage(context),
                        BlocBuilder<CommonBloc, CommonState>(
                          buildWhen: (previous, current) => previous.isLoading != current.isLoading,
                          builder: (context, state) {
                            return Visibility(visible: state.isLoading, child: buildPageLoading());
                          },
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget buildPageListeners({required Widget child}) => child;

  Widget buildPageLoading() => const Center(child: CircularProgressIndicator(color: primaryColor));

  Widget buildPage(BuildContext context);

  void handleException(AppExceptionWrapper appExceptionWrapper) {
    exceptionHandler
        .handleException(
          appExceptionWrapper,
          handleExceptionMessage(appExceptionWrapper.appException),
        )
        .then((_) => appExceptionWrapper.exceptionCompleter?.complete());
  }

  String handleExceptionMessage(AppException appException) {
    return exceptionMessageMapper.map(appException);
  }

  @override
  void onInvalidToken() => commonBloc.add(const ForceLogoutButtonPressed());
}
