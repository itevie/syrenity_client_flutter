import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';
import 'package:syrenity_client_flutter/theme.dart';

class ChannelBar extends StatefulWidget {
  const ChannelBar({super.key});

  @override
  State<StatefulWidget> createState() => _ChannelBarState();
}

class _ChannelBarState extends State<ChannelBar> {
  List<SyChannel> channels = [];
  int? _lastServerId;

  void load(int serverId) async {
    final loadedChannels = await client.channels.fetchChannelsForServer(
      serverId,
    );

    setState(() {
      channels = loadedChannels;
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
        Container(
          height: SyrenityTheme.topBarHeight,
          color: colors.surfaceContainer,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(server?.name ?? "Loading..."),
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

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  title: Text("#${c.name}"),
                  tileColor:
                      selected ? colors.primary.withValues(alpha: 0.24) : null,
                  hoverColor: colors.primary.withValues(alpha: 0.08),
                  onTap: () {
                    context.read<CurrentSettingsState>().setChannel(c.id);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
