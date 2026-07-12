import 'package:dawn_ui_flutter/util.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/util.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/fullscreen_image_viewer.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeServerUserAvatar(
  BuildContext context,
  int channelId,
  SyUser user,
) {
  (SyMember, SyServer) details;

  try {
    details = getMemberFromChannelAndUser(context, channelId, user);
  } catch (e) {
    return [
      ContextMenuButton(label: e.toString(), onPressed: () {}, danger: true),
    ];
  }

  final canKick =
      details.$2.ownerId == user.id
          ? false
          : details.$1.hasPermission(SyPermission.kickMembers);

  return [
    if (canKick)
      ContextMenuButton(
        label: "Kick ${user.username}",
        onPressed: () {},
        danger: true,
      ),
    ContextMenuSeparator(),
    ContextMenuButton(
      label: "View Avatar",
      onPressed: () {
        navigate(
          context,
          FullscreenImageViewer(
            imageUrls: [client.fileBase.from(user.avatar, size: 512)],
            initialIndex: 0,
          ),
        );
      },
    ),
    ContextMenuSeparator(),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "User ID", user.id.toString()),
  ];
}
