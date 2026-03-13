import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';
import 'package:syrenity_client_flutter/theme.dart';

class MessageWidget extends StatefulWidget {
  final SyMessage message;

  const MessageWidget({super.key, required this.message});

  @override
  State<StatefulWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: SyrenityTheme.messageSpacing),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(message.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
