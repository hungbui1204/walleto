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

    if (bloc.state.isSending) {
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
                child: BlocListener<AiChatBloc, AiChatState>(
                  listenWhen:
                      (previous, current) =>
                          previous.isSending != current.isSending ||
                          previous.messages.length != current.messages.length,
                  listener: (context, state) {
                    final pending = _pendingMessage;
                    if (!state.isSending && pending != null) {
                      final pendingStillVisible = state.messages.any(
                        (message) => message.role == AiChatRole.user && message.content == pending,
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
                  child: AiChatMessageListWidget(
                    scrollController: _scrollController,
                    onPromptSelected: _submit,
                  ),
                ),
              ),
              BlocBuilder<AiChatBloc, AiChatState>(
                buildWhen: (previous, current) => previous.isSending != current.isSending,
                builder: (context, state) {
                  return AiChatComposerWidget(
                    controller: _messageController,
                    isSending: state.isSending,
                    onSubmit: _submit,
                    onStop: () => bloc.add(const AiChatGenerationStopRequested()),
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
