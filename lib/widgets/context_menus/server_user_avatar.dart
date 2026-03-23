import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/channel_store.dart';
import 'package:syrenity_client_flutter/stores/member_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeServerUserAvatar(
  BuildContext context,
  int channelId,
  SyUser user,
) {
  final memberStore = context.read<MemberStore>();
  final serverStore = context.read<ServerStore>();
  final channelStore = context.read<ChannelStore>();

  final server = serverStore[channelStore[channelId]!.guildId!];

  if (server == null) {
    return [ContextMenuButton(label: "Server was null", onPressed: () {})];
  }

  final member = memberStore.get(server.id, user.id);

  if (member == null) {
    return [ContextMenuButton(label: "Member was null", onPressed: () {})];
  }

  final canKick =
      server.ownerId == user.id
          ? false
          : member.hasPermission(SyPermission.kickMembers);

  return [
    if (canKick)
      ContextMenuButton(
        label: "Kick ${user.username}",
        onPressed: () {},
        danger: true,
      ),
    ContextMenuSeparator(),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "User ID", user.id.toString()),
  ];
}
