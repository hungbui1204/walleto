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

  /// When true, [CommonBloc.isLoading] replaces the page body with a skeleton
  /// instead of overlaying [AppLoadingWidget] on the whole [Scaffold].
  bool get useSkeletonLoading => false;

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
          child: buildPageListeners(child: _buildPageContent(context)),
        ),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context) {
    if (isAppWidget || useSkeletonLoading) {
      return buildPage(context);
    }

    return Stack(
      children: [
        buildPage(context),
        BlocBuilder<CommonBloc, CommonState>(
          buildWhen: (previous, current) => previous.isLoading != current.isLoading,
          builder: (context, state) {
            return Visibility(visible: state.isLoading, child: buildPageLoading());
          },
        ),
      ],
    );
  }

  Widget buildPageListeners({required Widget child}) => child;

  Widget buildPageLoading() => const AppLoadingWidget();

  Widget buildSkeletonOrContent({required Widget skeleton, required Widget content}) {
    return _SkeletonOrContent(skeleton: skeleton, content: content);
  }

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

/// Keeps skeleton on screen for the first paint, before [CommonBloc.isLoading]
/// flips true, so empty states do not flash on tab open.
class _SkeletonOrContent extends StatefulWidget {
  const _SkeletonOrContent({required this.skeleton, required this.content});

  final Widget skeleton;
  final Widget content;

  @override
  State<_SkeletonOrContent> createState() => _SkeletonOrContentState();
}

class _SkeletonOrContentState extends State<_SkeletonOrContent> {
  bool _hasCompletedInitialLoad = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommonBloc, CommonState>(
      listenWhen: (previous, current) => previous.isLoading && !current.isLoading,
      listener: (context, state) {
        if (!_hasCompletedInitialLoad) {
          setState(() => _hasCompletedInitialLoad = true);
        }
      },
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        if (state.isLoading || !_hasCompletedInitialLoad) {
          return widget.skeleton;
        }

        return widget.content;
      },
    );
  }
}
