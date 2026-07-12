import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class FakeMessage {
  String content;

  FakeMessage({required this.content});
}

class BaseMainRight<T> extends StatefulWidget {
  final bool showPinned;
  final bool bySide;
  final int? channelId;
  final Widget? content;
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
  late void Function(SyMessage)? messageCreateCallback;
  late void Function(int)? messageDeleteCallback;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isDesktop =
        MediaQuery.of(context).size.width >= SyrenityTheme.mobileSize;

    if (widget.content == null) {
      return Column(
        children: [
          Container(
            height: SyrenityTheme.topBarHeight,
            color: colors.surfaceContainer,
            child: Container(
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
                    Spacer(),
                  ],
                ),
              ),
            ),
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
      child: Stack(
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
                        channel == null
                            ? const Icon(Icons.question_mark)
                            : channel.type == SyChannelType.todo
                            ? const Icon(Icons.task)
                            : const Icon(Icons.tag),
                        Text(
                          channel?.name ?? "Loading...",
                          // ${channel?.lastMessageAck != null} ${channel?.lastMessageAck?.messageId} <- ACK
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

              Expanded(child: widget.content!),

              if (!widget.bySide && widget.typer != null) ...[widget.typer!],
            ],
          ),
        ],
      ),
    );
  }
}
