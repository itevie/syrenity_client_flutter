import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/message_cm.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/server_user_avatar.dart';
import 'package:syrenity_client_flutter/widgets/inline_username.dart';
import 'package:syrenity_client_flutter/widgets/message_image.dart';
import 'package:syrenity_client_flutter/widgets/message_markdown.dart';
import 'package:syrenity_client_flutter/widgets/modals/user_viewer.dart';
import 'package:syrenity_client_flutter/widgets/pages/main/channel_types/components/embed.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/show_dialog.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MessageWidget extends StatefulWidget {
  final SyMessage message;
  final int? newestMessage;
  final bool isSending;

  const MessageWidget({
    super.key,
    required this.message,
    this.newestMessage,
    this.isSending = false,
  });

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
    final markdown = message.parseMarkdown();

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: ContextMenu(
                  items:
                      () => makeMessageContextMenu(
                        context,
                        client.user,
                        message,
                        edit: () {
                          setState(() {
                            controller.value = TextEditingValue(
                              text: message.content,
                            );
                            editing = true;
                          });
                        },
                      ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InlineUsername(user: message.authorId),

                          const SizedBox(width: 4),
                          Text(
                            formatMessageDate(message.createdAt),
                            style: TextStyle(color: Colors.grey),
                          ),

                          // if (widget.isSending) ...[
                          //   const SizedBox(width: 4),

                          //   const Text(
                          //     "Sending...",
                          //     style: TextStyle(color: Colors.grey),
                          //   ),
                          //   const Icon(Icons.schedule, color: Colors.grey),
                          // ],
                        ],
                      ),
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
                                  onPressed: () async {
                                    await message.edit(
                                      MessageEditOptions(
                                        content: controller.text,
                                      ),
                                    );

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
                        Row(
                          children: [
                            MessageMarkdown(
                              parsed: markdown,
                              isSending: widget.isSending,
                            ),
                            if (widget.message.isEdited) ...[
                              const SizedBox(width: 4),
                              Text(
                                "(edited)",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        )
                      else
                        Text(
                          message.content,
                          style:
                              widget.isSending
                                  ? TextStyle(color: Colors.grey)
                                  : null,
                        ),
                      if (markdown.objects.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: Wrap(
                            children: [
                              ...markdown.objects
                                  .whereType<LinkObjectType>()
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final x = entry.value;

                                    return MessageImage(
                                      key: ValueKey(
                                        "${message.id}-${x.url}-$index",
                                      ),
                                      url: x.url,
                                      allImages:
                                          markdown.objects
                                              .whereType<LinkObjectType>()
                                              .map((e) => e.url)
                                              .toList(),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                      if (message.embeds.isNotEmpty)
                        ...message.embeds.map(
                          (x) => Embed(x, key: Key(x.id.toString())),
                        ),
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

String formatMessageDate(DateTime date) {
  final now = DateTime.now();

  final isToday =
      now.year == date.year && now.month == date.month && now.day == date.day;

  if (isToday) {
    // Only time
    return DateFormat('HH:mm').format(date);
  }

  // Full date + time
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}
