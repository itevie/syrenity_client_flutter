import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/message.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right_events.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/member_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/message_bar.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/typing_indicator.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class FakeMessage {
  String content;

  FakeMessage({required this.content});
}

class BaseMainRight<T> extends StatefulWidget {
  final bool showPinned;
  final bool bySide;
  final int? channelId;
  final Widget content;
  final Widget? typer;
  final List<Widget>? actions;
  final VoidCallback? loadMore;

  const BaseMainRight({
    super.key,
    required this.channelId,
    required this.content,
    this.loadMore,
    this.actions,
    this.typer,
    this.showPinned = false,
    this.bySide = false,
  });

  @override
  State<StatefulWidget> createState() => _BaseMainRightState();
}

class _BaseMainRightState<T> extends State<BaseMainRight<T>> {
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
        if (widget.loadMore != null) {
          widget.loadMore!();
        }
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
                            Spacer(),
                            if (!currentSettings.sidebarShown &&
                                widget.actions != null) ...[
                              ...widget.actions!,
                            ],
                          ],
                        ),
                      ),
                    ),

                  Expanded(child: widget.content),

                  if (!widget.bySide && widget.typer != null) ...[
                    widget.typer!,
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
