import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/util.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class CreateChannelDialog extends StatefulWidget {
  const CreateChannelDialog({super.key});

  @override
  State<CreateChannelDialog> createState() => _CreateChannelDialogState();
}

class _CreateChannelDialogState extends State<CreateChannelDialog> {
  void createChannel(SyChannelType type) async {
    final channelName = await showInputPrompt(
      context,
      Text("Channel Name:"),
      null,
    );

    if (channelName == null || channelName.isEmpty) {
      return;
    }

    final server = getCurrentServer(context);
    if (server == null) return;

    await server.channels.createChannel(type, channelName);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                const Text(
                  "Select which type of channel you'd like to create.",
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    createChannel(SyChannelType.channel);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.tag, size: 32),
                      SizedBox(width: 8),
                      Text("Text Channel"),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    createChannel(SyChannelType.todo);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.task, size: 32),
                      SizedBox(width: 8),
                      Text("Todo Channel"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}
