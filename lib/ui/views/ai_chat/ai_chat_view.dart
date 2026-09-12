import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleto/domain/domain.dart';
import 'package:walleto/resources/resources.dart';
import 'package:walleto/shared/shared.dart';
import 'package:walleto/ui/ui.dart';

@RoutePage()
class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends BasePageState<AiChatView, AiChatBloc> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  String? _pendingMessage;

  @override
  bool get useSkeletonLoading => true;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    bloc.add(const AiChatViewInitiated());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - Dimens.d80.responsive()) {
      bloc.add(const AiChatLoadMoreRequested());
    }
  }

  void _submit(String rawMessage) {
    final message = rawMessage.trim();
    if (message.isEmpty) {
      return;
    }

    ViewUtils.hideKeyboard(context);
    _pendingMessage = message;
    _messageController.clear();
    bloc.add(AiChatMessageSubmitted(message: message));
  }

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => ViewUtils.hideKeyboard(context),
      child: Scaffold(
        appBar: CommonAppBar(title: S.current.aiAssistant),
        body: NoirScaffoldBody(
          child: Column(
            children: [
              Expanded(
                child: buildSkeletonOrContent(
                  skeleton: const AiChatLoadingSkeletonWidget(),
                  content: BlocConsumer<AiChatBloc, AiChatState>(
                    listenWhen:
                        (previous, current) =>
                            (previous.isSending && !current.isSending) ||
                            (current.isSending &&
                                current.messages.length == previous.messages.length + 1),
                    listener: (context, state) {
                      final pending = _pendingMessage;
                      if (!state.isSending && pending != null) {
                        final pendingStillVisible = state.messages.any(
                          (message) =>
                              message.role == AiChatRole.user &&
                              message.content == pending &&
                              message.id == 0,
                        );
                        if (!pendingStillVisible) {
                          _messageController.text = pending;
                        }
                        _pendingMessage = null;
                      }

                      if (!_scrollController.hasClients) {
                        return;
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_scrollController.hasClients) {
                          return;
                        }
                        _scrollController.animateTo(
                          0,
                          duration: DurationConstants.defaultAnimationScrollDuration,
                          curve: Curves.easeOut,
                        );
                      });
                    },
                    buildWhen:
                        (previous, current) =>
                            previous.messages != current.messages ||
                            previous.isSending != current.isSending ||
                            previous.isLoadingMore != current.isLoadingMore,
                    builder: (context, state) {
                      if (state.isEmpty) {
                        return AiChatEmptyStateWidget(onPromptSelected: _submit);
                      }

                      final itemCount = state.messages.length + (state.isSending ? 1 : 0);

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: Dimens.d16.responsive()),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (state.isSending && index == 0) {
                            return const AiChatTypingIndicatorWidget();
                          }

                          final messageIndex =
                              state.isSending
                                  ? state.messages.length - index
                                  : state.messages.length - 1 - index;

                          return AiChatMessageBubbleWidget(message: state.messages[messageIndex]);
                        },
                      );
                    },
                  ),
                ),
              ),
              BlocBuilder<CommonBloc, CommonState>(
                buildWhen: (previous, current) => previous.isLoading != current.isLoading,
                builder: (context, commonState) {
                  return BlocBuilder<AiChatBloc, AiChatState>(
                    buildWhen: (previous, current) => previous.isSending != current.isSending,
                    builder: (context, state) {
                      return AiChatComposerWidget(
                        controller: _messageController,
                        enabled: !state.isSending && !commonState.isLoading,
                        onSubmit: _submit,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
