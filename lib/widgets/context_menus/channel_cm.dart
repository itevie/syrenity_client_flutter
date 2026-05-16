import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/channel_settings_parts.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeChannelContextMenu(
  BuildContext context,
  SyChannel channel,
) {
  return [
    ContextMenuButton(
      label: "Manage",
      icon: Icons.edit,
      onPressed: () {
        navigate(
          context,
          SettingsPage(
            name: "#${channel.name} Settings",
            sections: [ChannelSettingsParts.about(context)],
          ),
        );
      },
    ),
    ContextMenuSeparator(),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "Channel ID", channel.id.toString()),
  ];
}
