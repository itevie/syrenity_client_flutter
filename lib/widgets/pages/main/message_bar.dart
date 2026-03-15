import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/channel.dart';
import 'package:flutter/services.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/setting_listener.dart';

final Map<int, String> channelDrafts = {};

class MessageBar extends StatefulWidget {
  final SyChannel? channel;
  const MessageBar({super.key, required this.channel});

  @override
  State<StatefulWidget> createState() => _MessageBarState();
}

class _MessageBarState extends State<MessageBar> {
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty || widget.channel == null) return;

    widget.channel?.send(text);

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
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),

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
                      channel?.startTyping();
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
                onPressed: () {},
              ),
            ),

            SettingListener(
              setting: SettingKeys.showEmojiPickerButton,
              child: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: () {},
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
