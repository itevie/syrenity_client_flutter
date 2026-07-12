import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/channel_name.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings.dart';
import 'package:syrenity_client_flutter/widgets/todo.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ServerChannelOrderSettings extends StatefulWidget {
  const ServerChannelOrderSettings({super.key});

  @override
  State<ServerChannelOrderSettings> createState() =>
      _ServerChannelOrderSettingsState();
}

class _ServerChannelOrderSettingsState
    extends State<ServerChannelOrderSettings> {
  List<SyChannel> channels = [];
  Map<int, int> channelOrder = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (updateSettingsPagesPage != null) {
        updateSettingsPagesPage!(
          PageOptions(page: null, fab: (save, Icons.save)),
        );
      }

      load();
    });
  }

  int? _channelId(SyChannel channel) => channel.id;

  int? _channelPosition(SyChannel channel) => channel.position;

  Future<void> load() async {
    var settings = context.read<CurrentSettingsState>();
    var serverId = settings.serverId;

    if (serverId == null) return;

    var channels = await client.channels.fetchChannelsForServer(serverId);

    setState(() {
      this.channels = channels;
      channelOrder = Map.fromEntries(
        channels
            .map((c) {
              final id = _channelId(c);
              final pos = _channelPosition(c);
              return MapEntry(id, pos ?? -1);
            })
            .where((e) => e.key != null)
            .map((e) => MapEntry(e.key as int, e.value))
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value)),
      );

      print(
        Map.fromEntries(
          channels
              .map((c) {
                final id = _channelId(c);
                final pos = _channelPosition(c);
                return MapEntry(id, pos ?? -1);
              })
              .where((e) => e.key != null)
              .map((e) => MapEntry(e.key as int, e.value))
              .toList()
            ..sort((a, b) => a.value.compareTo(b.value)),
        ),
      );
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final channel = channels.removeAt(oldIndex);
      channels.insert(newIndex, channel);
      // rebuild map: channelId -> new position (index)
      channelOrder = {};
      for (var i = 0; i < channels.length; i++) {
        final id = _channelId(channels[i]);
        if (id != null) channelOrder[id] = i + 1;
      }
    });
  }

  Future<void> save() async {
    var settings = context.read<CurrentSettingsState>();
    var servers = context.read<ServerStore>();
    var serverId = settings.serverId;

    if (serverId == null) return;
    var server = servers[serverId];
    if (server == null) return;

    updateSettingsPagesPage!(
      PageOptions(page: null, fab: (save, Icons.hourglass_empty)),
    );

    await server.updateChannelOrder(channelOrder);

    updateSettingsPagesPage!(PageOptions(page: null, fab: (save, Icons.save)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (channels.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: ReorderableListView.builder(
              onReorder: _onReorder,
              itemCount: channelOrder.length,
              itemBuilder: (context, index) {
                final channelId = channelOrder.keys.elementAt(index);
                final channel = channels.firstWhere(
                  (c) => _channelId(c) == channelId,
                );
                return ListTile(
                  key: ValueKey(_channelId(channel) ?? index),
                  title: channelName(channel),
                  trailing: const Icon(Icons.drag_handle),
                );
              },
            ),
          ),

        const Text(
          "Drag and drop channels to reorder them. Press the save button to apply changes.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
