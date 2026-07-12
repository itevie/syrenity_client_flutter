import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:flutter/services.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/main_right.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/setting_listener.dart';
import 'package:syrenity_client_flutter/widgets/todo.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

final Map<int, String> channelDrafts = {};

class MessageBar extends StatefulWidget {
  final SyChannel? channel;
  final Function(int, FakeMessage) addFakeMessage;
  final Function(int) removeFakeMessage;

  const MessageBar({
    super.key,
    required this.channel,
    required this.addFakeMessage,
    required this.removeFakeMessage,
  });

  @override
  State<StatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Future<void> _sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || widget.channel == null) return;

    final random = Random();

    final value = -random.nextInt(1 << 31) - 1;
    widget.addFakeMessage(value, FakeMessage(content: text));

    await widget.channel?.asTextChannel().send(text);

    widget.removeFakeMessage(value);

    controller.clear();
    channelDrafts.remove(widget.channel!.id);
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (widget.channel != null) {
        channelDrafts[widget.channel!.id] = controller.text;
      }
    });

    if (widget.channel != null) {
      _loadDraft();
    }
  }

  @override
  void didUpdateWidget(MessageBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.channel != widget.channel) {
      if (oldWidget.channel != null) {
        channelDrafts[oldWidget.channel!.id] = controller.text;
      }

      if (widget.channel != null) {
        _loadDraft();
      }
    }
  }

  void _loadDraft() {
    final draft = channelDrafts[widget.channel!.id];
    controller.text = draft ?? "";
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  @override
  void dispose() {
    if (widget.channel != null) {
      channelDrafts[widget.channel!.id] = controller.text;
    }
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentSettings = context.watch<CurrentSettingsState>();

    final channel =
        currentSettings.channelId == null
            ? null
            : context.select<ChannelStore, SyChannel?>(
              (x) => x[currentSettings.channelId!],
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
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.pickFiles();

                if (result != null) {
                  PlatformFile file = result.files.first;

                  final returnedFile = await client.files.upload(file);

                  controller.text +=
                      returnedFile.url ?? "<f:${returnedFile.id}>";
                } else {
                  print("User cancelled");
                }
              },
            ),

            Expanded(
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.enter): _SendIntent(),
                },
                child: Actions(
                  actions: {
                    _SendIntent: CallbackAction<_SendIntent>(
                      onInvoke: (intent) {
                        _sendMessage();
                        return null;
                      },
                    ),
                  },
                  child: TextField(
                    focusNode: _focusNode,
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    onChanged: (_) {
                      channel?.asTextChannel().startTyping();
                    },
                    decoration: InputDecoration(
                      hintText: "Message #${channel?.name ?? "Loading..."}",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            SettingListener(
              setting: SettingKeys.showGifPickerButton,
              child: IconButton(
                icon: const Icon(Icons.gif_box_outlined),
                onPressed: () {
                  todo(context);
                },
              ),
            ),

            SettingListener(
              setting: SettingKeys.showEmojiPickerButton,
              child: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {
                  todo(context);
                },
              ),
            ),

            SettingListener(
              setting: SettingKeys.showSendMessageButton,
              child: IconButton(
                onPressed: () {
                  _sendMessage();
                },
                icon: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendIntent extends Intent {
  const _SendIntent();
}
