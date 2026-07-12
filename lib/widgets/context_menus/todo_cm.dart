import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/util.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeTodoContextMenu(
  BuildContext context,
  SyUser user,
  SyTodoItem todo, {
  required VoidCallback edit,
}) {
  (SyMember, SyServer) details;

  try {
    details = getMemberFromChannelAndUser(context, todo.channelId, user);
  } catch (e) {
    return [
      ContextMenuButton(label: e.toString(), onPressed: () {}, danger: true),
    ];
  }

  final canManageMessage =
      details.$2.ownerId == user.id
          ? true
          : details.$1.hasPermission(SyPermission.manageMessages);

  final canDelete = user.id == todo.authorId || canManageMessage;

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
          await todo.delete();
        },
      ),
    ContextMenuSeparator(),
    makeCopyContextMenuButton(context, "Todo Name", todo.name),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "Todo ID", todo.id.toString()),
  ];
}
