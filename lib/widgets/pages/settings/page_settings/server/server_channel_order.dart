import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  int? _channelId(SyChannel channel) => channel.id;

  int? _channelPosition(SyChannel channel) => channel.position;

  String _channelTitle(SyChannel channel) {
    final dynamic ch = channel;
    final name = ch.name;
    final id = ch.id;
    if (name is String && name.isNotEmpty) {
      return name;
    }
    if (id != null) {
      return 'Channel $id';
    }
    return channel.toString();
  }

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
            .map((e) => MapEntry(e.key as int, e.value)),
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
        if (id != null) channelOrder[id] = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Server Channel Order Settings'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                todo(context);
              },
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (channels.isEmpty)
          const Text('No channels loaded yet.')
        else
          Expanded(
            child: ReorderableListView.builder(
              onReorder: _onReorder,
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ListTile(
                  key: ValueKey(_channelId(channel) ?? index),
                  title: Text(_channelTitle(channel)),
                  trailing: const Icon(Icons.drag_handle),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Order: ${channelOrder.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
        ),
      ],
    );
  }
}
