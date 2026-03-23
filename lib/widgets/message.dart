import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/server_user_avatar.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/inline_username.dart';
import 'package:syrenity_client_flutter/widgets/message_markdown.dart';
import 'package:syrenity_client_flutter/widgets/modals/user_viewer.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/show_dialog.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MessageWidget extends StatefulWidget {
  final SyMessage message;
  final int? newestMessage;

  const MessageWidget({super.key, required this.message, this.newestMessage});

  @override
  State<StatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool editing = false;

  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final message = widget.message;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // handle tap if needed
        },
        child: Padding(
          padding:
              widget.newestMessage == message.id
                  ? EdgeInsets.zero
                  : EdgeInsetsDirectional.only(
                    bottom: SyrenityTheme.messageSpacing / 2,
                    top: SyrenityTheme.messageSpacing / 2,
                  ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ContextMenu(
                items:
                    () => makeServerUserAvatar(
                      context,
                      message.channelId,
                      message.author,
                    ),
                child: GestureDetector(
                  onTap: () {
                    showSyDialog(
                      context,
                      UserViewerModal(user: message.author),
                    );
                  },
                  child: CircleAvatar(
                    key: Key(message.id.toString()),
                    radius: SyrenityTheme.messageAvatarSize,
                    backgroundImage: NetworkImage(
                      client.fileBase.from(
                        message.author.avatar ?? client.fileBase.badUrl,
                      )!,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: ContextMenu(
                  items:
                      () => [
                        ContextMenuButton(
                          onPressed: () async {
                            setState(() {
                              controller.value = TextEditingValue(
                                text: message.content,
                              );
                              editing = true;
                            });
                          },
                          label: "Edit",
                          icon: Icons.edit,
                        ),
                        ContextMenuButton(
                          onPressed: () async {
                            await message.delete();
                          },
                          label: "Delete",
                          icon: Icons.delete,
                          danger: true,
                        ),
                        ContextMenuSeparator(),

                        makeCopyContextMenuButton(
                          context,
                          "Message Content",
                          message.content,
                        ),
                        if (SettingsStorage.instance.getSetting<bool>(
                          SettingKeys.developerMode,
                        ))
                          makeCopyContextMenuButton(
                            context,
                            "Message ID",
                            message.id.toString(),
                          ),
                      ],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InlineUsername(user: message.authorId),
                      const SizedBox(height: 4),
                      if (editing)
                        Column(
                          children: [
                            Shortcuts(
                              shortcuts: const {
                                SingleActivator(LogicalKeyboardKey.enter):
                                    _SendIntent(),
                              },
                              child: Actions(
                                actions: {
                                  _SendIntent: CallbackAction<_SendIntent>(
                                    onInvoke: (intent) {
                                      return null;
                                    },
                                  ),
                                },
                                child: TextField(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: colors.surfaceContainer,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  focusNode: _focusNode,
                                  controller: controller,
                                  minLines: 1,
                                  maxLines: 5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      editing = false;
                                    });
                                  },
                                  child: const Text("Cancel"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      editing = false;
                                    });
                                  },
                                  child: const Text("Save"),
                                ),
                              ],
                            ),
                          ],
                        )
                      else if (SettingsStorage.instance.getSetting<bool>(
                        SettingKeys.parseMarkdownInMessages,
                      ))
                        MessageMarkdown(parsed: message.parseMarkdown())
                      else
                        Text(message.content),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendIntent extends Intent {
  const _SendIntent();
}
