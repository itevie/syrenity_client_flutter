import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/message.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/base.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/controllers/text_channel_controller.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/member_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/bars/message_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/typing_indicator.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class TextChannel extends StatefulWidget {
  final bool showPinned;
  final bool bySide;
  final int? channelId;

  const TextChannel({
    super.key,
    this.channelId,
    this.showPinned = false,
    this.bySide = false,
  });

  @override
  State<TextChannel> createState() => _TextChannelState();
}

class _TextChannelState extends State<TextChannel> {
  bool _showScrollToBottom = false;

  ChannelMessagesController? controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.channelId == null) return;

    final channelStore = context.read<ChannelStore>();

    controller = ChannelMessagesController(
      channelId: widget.channelId!,
      channelStore: channelStore,
      showPinned: widget.showPinned,
      noEvents: widget.bySide,
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !controller!.isLoadingMore) {
        controller!.loadMessages(isInitial: true);
      }

      if (_scrollController.hasClients) {
        final scrolledUpEnough = _scrollController.offset > 1000;
        if (_showScrollToBottom == scrolledUpEnough) return;

        setState(() {
          _showScrollToBottom = scrolledUpEnough;
        });
      }
    });

    controller!.init();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final channel =
        widget.channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (store) => store[widget.channelId!],
            );

    return BaseMainRight(
      key: Key(widget.channelId.toString()),
      channelId: widget.channelId,
      bySide: widget.bySide,
      showPinned: widget.showPinned,
      content:
          (controller == null || channel == null)
              ? null
              : AnimatedBuilder(
                animation: controller!,
                builder: (context, child) {
                  return Stack(
                    children: [
                      controller!.initialLoading
                          ? const Center(child: CircularProgressIndicator())
                          : controller!.messages.isEmpty
                          ? const Center(child: Text("So empty..."))
                          : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.all(10),
                            itemCount: controller!.messages.length,
                            itemBuilder: (context, index) {
                              final msg = controller!.messages[index];
                              return MessageWidget(
                                isSending: msg.id < -1,
                                message: msg,
                                newestMessage: controller!.messages[0].id,
                              );
                            },
                          ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Visibility(
                          visible: _showScrollToBottom,
                          child: FloatingActionButton(
                            mini: true,
                            onPressed: _scrollToBottom,
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      actions: [
        IconButton(
          icon: Icon(Icons.push_pin),
          onPressed: () {
            if (MainCallbacks.setSidebar != null) {
              MainCallbacks.setSidebar!((
                const Text("Pinned"),
                Expanded(
                  child: TextChannel(
                    channelId: widget.channelId,
                    key: Key("pinned-${widget.channelId}"),
                    showPinned: true,
                    bySide: true,
                  ),
                ),
              ));
            }
          },
        ),

        IconButton(
          icon: Icon(Icons.group),
          onPressed: () {
            if (MainCallbacks.setSidebar != null) {
              MainCallbacks.setSidebar!((const Text("Members"), MemberBar()));
            }
          },
        ),
      ],
      typer: Column(
        children: [
          TypingIndicator(channelId: widget.channelId),
          MessageBar(
            key: ValueKey(widget.channelId),
            channel: channel,
            addFakeMessage: (id, msg) {
              controller!.addFakeMessage(
                SyMessage(
                  client,
                  id: id,
                  content: msg.content,
                  channelId: widget.channelId!,
                  createdAt: DateTime.now(),
                  authorId: client.user.id,
                  author: client.user,
                  isPinned: false,
                  isEdited: false,
                  isSystem: false,
                  sysType: null,
                  reactions: [],
                  embeds: [],
                  webhookId: null,
                  webhook: null,
                  proxyId: null,
                ),
              );
            },
            removeFakeMessage: (id) {
              controller!.removeFakeMessage(id);
            },
          ),
        ],
      ),
    );
  }
}
