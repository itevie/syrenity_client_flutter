import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/message.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/controllers/text_channel_controller.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/member_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/bars/message_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/typing_indicator.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class FakeMessage {
  String content;

  FakeMessage({required this.content});
}

class MainRight extends StatefulWidget {
  final bool showPinned;
  final bool bySide;
  final int? channelId;

  const MainRight({
    super.key,
    required this.channelId,
    this.showPinned = false,
    this.bySide = false,
  });

  @override
  State<StatefulWidget> createState() => _MainRightState();
}

class _MainRightState extends State<MainRight> {
  bool _showScrollToBottom = false;

  late void Function(SyMessage)? messageCreateCallback;
  late void Function(int)? messageDeleteCallback;

  final ScrollController _scrollController = ScrollController();
  ChannelMessagesController? controller;

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
    controller!.init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50 &&
          !controller!.isLoadingMore) {
        controller!.loadMessages(isInitial: false);
      }

      if (_scrollController.hasClients) {
        final scrolledUpEnough = _scrollController.offset > 1000;
        if (_showScrollToBottom == scrolledUpEnough) return;

        setState(() {
          _showScrollToBottom = scrolledUpEnough;
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
    final colors = Theme.of(context).colorScheme;

    if (controller == null) {
      return Column(
        children: [
          Container(
            height: SyrenityTheme.topBarHeight,
            color: colors.surfaceContainer,
          ),
          Expanded(child: const Center(child: Text("Click a channel!"))),
          Container(
            height: SyrenityTheme.bottomBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 4),

            decoration: BoxDecoration(color: colors.inversePrimary),
          ),
        ],
      );
    }

    final isDesktop =
        MediaQuery.of(context).size.width >= SyrenityTheme.mobileSize;
    final currentSettings = context.watch<CurrentSettingsState>();

    final channelId = currentSettings.channelId;

    final channel =
        channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (store) => store[channelId],
            );

    return Container(
      color: widget.bySide ? colors.primaryContainer : colors.surface,
      child: AnimatedBuilder(
        animation: controller!,
        builder: (context, _) {
          return Stack(
            children: [
              Column(
                children: [
                  if (!widget.bySide)
                    Container(
                      height: SyrenityTheme.topBarHeight,
                      color: colors.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            if (!isDesktop) ...[
                              IconButton(
                                onPressed: () {
                                  MainCallbacks.setDrawerVisibility?.call(true);
                                },
                                icon: const Icon(Icons.menu),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              "#${channel?.name ?? "Loading..."} ${channel?.lastMessageAck != null} ${channel?.lastMessageAck?.messageId} <- ACK",
                            ),
                            if (!currentSettings.sidebarShown) ...[
                              Spacer(),

                              IconButton(
                                icon: Icon(Icons.push_pin),
                                onPressed: () {
                                  if (MainCallbacks.setSidebar != null) {
                                    MainCallbacks.setSidebar!((
                                      const Text("Pinned"),
                                      Expanded(
                                        child: MainRight(
                                          channelId: widget.channelId,
                                          key: Key(
                                            "pinned-${widget.channelId}",
                                          ),
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
                                    MainCallbacks.setSidebar!((
                                      const Text("Members"),
                                      MemberBar(),
                                    ));
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  Expanded(
                    child:
                        channel == null
                            ? const Center(child: Text("Click a channel!"))
                            : Stack(
                              children: [
                                controller!.initialLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
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
                                          newestMessage:
                                              controller!.messages[0].id,
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
                            ),
                  ),

                  if (!widget.bySide) ...[
                    TypingIndicator(channelId: widget.channelId),
                    MessageBar(
                      key: ValueKey(channelId),
                      channel: channel,
                      addFakeMessage: (id, msg) {
                        controller!.addFakeMessage(
                          SyMessage(
                            client,
                            id: id,
                            content: msg.content,
                            channelId: channelId!,
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
