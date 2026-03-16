import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/syrenity_client/content_parser/lexer.dart';
import 'package:syrenity_client_flutter/syrenity_client/content_parser/parser.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/message_markdown.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';

class MessageWidget extends StatefulWidget {
  final SyMessage message;
  final int? newestMessage;

  const MessageWidget({super.key, required this.message, this.newestMessage});

  @override
  State<StatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    final lexed = lex(message.content);
    final parsed = new SyContentParser(lexed).parse();

    print(parsed.tokens.map((x) => x.toString()));

    return ContextMenu(
      items:
          () => [
            ContextMenuButton(
              onPressed: () async {
                // await message.delete();
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
      child: Material(
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
                CircleAvatar(
                  key: Key(message.id.toString()),
                  radius: SyrenityTheme.messageAvatarSize,
                  backgroundImage: NetworkImage(
                    client.fileBase.from(
                      message.author.avatar ?? client.fileBase.badUrl,
                    )!,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${message.author.username}: ${message.id}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      MessageMarkdown(parsed: parsed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
