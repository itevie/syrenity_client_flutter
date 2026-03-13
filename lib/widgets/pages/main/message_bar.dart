import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';

class MessageBar extends StatefulWidget {
  const MessageBar({super.key});

  @override
  State<StatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentSettings = context.watch<CurrentSettingsState>();

    final channel =
        currentSettings.channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (x) =>
                  currentSettings.channelId == null
                      ? null
                      : x[currentSettings.channelId!],
            );

    return Container(
      padding: const EdgeInsets.all(12),
      color: colors.inversePrimary,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),

            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Message #${channel?.name ?? "Loading..."}",
                  border: InputBorder.none,
                ),
              ),
            ),

            IconButton(
              icon: const Icon(Icons.gif_box_outlined),
              onPressed: () {},
            ),

            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
