import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/channel_cm.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/server_cm.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/channel_name.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ChannelBar extends StatefulWidget {
  const ChannelBar({super.key});

  @override
  State<StatefulWidget> createState() => _ChannelBarState();
}

class _ChannelBarState extends State<ChannelBar> {
  List<SyChannel> channels = [];
  int? _lastServerId;

  void Function(SpecialDispatchChannelUpdateOrder)? channelOrderUpdateCallback;

  @override
  void initState() {
    super.initState();

    channelOrderUpdateCallback = (update) {
      if (update.guildId == null || update.guildId != _lastServerId) return;
      load(_lastServerId!);
    };

    client.events.on(
      SyEvents.dispatchChannelOrderUpdate,
      channelOrderUpdateCallback!,
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (channelOrderUpdateCallback != null) {
      client.events.off(
        SyEvents.dispatchChannelOrderUpdate,
        channelOrderUpdateCallback!,
      );
      channelOrderUpdateCallback = null;
    }
  }

  void load(int serverId) async {
    setState(() {
      channels = [];
    });

    final loadedChannels = await client.channels.fetchChannelsForServer(
      serverId,
    );

    setState(() {
      channels = loadedChannels;
      channels.sort((a, b) => a.position - b.position);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentSettings = context.watch<CurrentSettingsState>();

    final server =
        currentSettings.serverId == null
            ? null
            : context.select<ServerStore, SyServer?>(
              (x) => x[currentSettings.serverId!],
            );

    if (currentSettings.serverId != null &&
        currentSettings.serverId != _lastServerId) {
      _lastServerId = currentSettings.serverId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        load(currentSettings.serverId!);
      });
    }

    return Column(
      children: [
        ContextMenu(
          asyncItems:
              () async =>
                  server == null ? [] : makeServerContextMenu(context, server),
          child: Container(
            height: SyrenityTheme.topBarHeight,
            color: colors.surfaceContainer,
            // color: colors.inversePrimary,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(server?.name ?? "Loading..."),
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: colors.secondaryContainer,
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, i) {
                final c = channels[i];
                final selected = currentSettings.channelId == c.id;

                return ContextMenu(
                  items: () => makeChannelContextMenu(context, c),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    title: channelName(c),
                    tileColor:
                        selected
                            ? colors.primary.withValues(alpha: 0.24)
                            : null,
                    hoverColor: colors.primary.withValues(alpha: 0.08),
                    onTap: () {
                      if (MainCallbacks.setDrawerVisibility != null) {
                        MainCallbacks.setDrawerVisibility!(false);
                      }
                      context.read<CurrentSettingsState>().setChannel(c.id);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
