import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/dispatch_messages.dart';
import 'package:syrenity_client_flutter/syrenity_client/events.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/message.dart';

typedef _UserTyping = (int userId, DateTime startedAt);

class TypingIndicator extends StatefulWidget {
  final int? channelId;

  const TypingIndicator({super.key, required this.channelId});

  @override
  State<StatefulWidget> createState() => _TypingIdicatorState();
}

class _TypingIdicatorState extends State<TypingIndicator> {
  List<_UserTyping> typing = [];
  void Function(DispatchChannelStartTyping)? typingCallback;
  void Function(SyMessage)? messageCallback;
  Timer? _timer;

  @override
  void initState() {
    typingCallback = (ev) {
      setState(() {
        typing = checkOld();
        if (typing.where((x) => x.$1 == ev.userId).isEmpty) {
          typing.add((ev.userId, DateTime.now()));
        }
      });
    };
    client.events.on(SyEvents.dispatchChannelStartTyping, typingCallback!);

    messageCallback = (message) {
      if (message.channelId != widget.channelId) return;

      setState(() {
        typing = typing.where((x) => x.$1 != message.author.id).toList();
      });
    };
    client.events.on(SyEvents.dispatchCreateMessage, messageCallback!);

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;

      setState(() {
        typing = checkOld();
      });
    });

    super.initState();
  }

  List<_UserTyping> checkOld() {
    return typing
        .where((x) => DateTime.now().difference(x.$2).inSeconds < 3)
        .toList();
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (typingCallback != null) {
      client.events.off(SyEvents.dispatchChannelStartTyping, typingCallback!);
      typingCallback = null;
    }

    if (messageCallback != null) {
      client.events.off(SyEvents.dispatchCreateMessage, messageCallback!);
      messageCallback = null;
    }

    super.dispose();
  }

  String buildTypingIndicatorMessage(List<String> users) {
    String usersPart = "";

    if (users.isEmpty) return "";

    if (users.length == 1) {
      usersPart = users[0];
    } else if (users.length == 2) {
      usersPart = "${users[0]} and ${users[1]}";
    } else {
      for (final user in users) {
        usersPart += user;

        if (users.indexOf(user) == users.length - 1) {
          usersPart += "and";
        } else {
          usersPart += ", ";
        }
      }
    }

    return "$usersPart ${users.length == 1 ? "is" : "and"} typing...";
  }

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 24,
      color: colors.surface,
      padding: const EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          buildTypingIndicatorMessage(
            typing
                .map(
                  (x) =>
                      userStore.all.firstWhere((y) => y.id == x.$1).username
                          as String? ??
                      "Loading...",
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
