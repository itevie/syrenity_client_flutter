import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/util.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeMessageContextMenu(
  BuildContext context,
  SyUser user,
  SyMessage message, {
  required VoidCallback edit,
}) {
  (SyMember, SyServer) details;

  try {
    details = getMemberFromChannelAndUser(context, message.channelId, user);
  } catch (e) {
    return [
      ContextMenuButton(label: e.toString(), onPressed: () {}, danger: true),
    ];
  }

  final canManageMessage =
      details.$2.ownerId == user.id
          ? true
          : details.$1.hasPermission(SyPermission.manageMessages);

  print({
    'owner': details.$2.ownerId,
    'current': user.id,
    'permissions': details.$1.permissions,
    'result': canManageMessage,
  });

  final canDelete = user.id == message.authorId || canManageMessage;

  return [
    ContextMenuButton(
      label: "Edit",
      icon: Icons.edit,
      onPressed: () {
        edit();
      },
    ),
    if (canDelete)
      ContextMenuButton(
        label: "Delete",
        danger: true,
        icon: Icons.delete,
        onPressed: () async {
          await message.delete();
        },
      ),
    ContextMenuSeparator(),
    if (canManageMessage)
      ContextMenuButton(
        label: "${message.isPinned ? "Unpin" : "Pin"} Message",
        icon: message.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
        onPressed: () async {
          if (message.isPinned) {
            await message.unpin();
          } else {
            await message.pin();
          }
        },
      ),
    ContextMenuSeparator(),
    makeCopyContextMenuButton(context, "Message Content", message.content),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "Message ID", message.id.toString()),
  ];
}
