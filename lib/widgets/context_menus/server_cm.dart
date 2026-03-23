import 'package:dawn_ui_flutter/prompts/confirm.dart';
import 'package:dawn_ui_flutter/prompts/message.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/setting_parts.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> Function() makeServerContextMenu(
  BuildContext context,
  SyServer server,
) {
  return () => [
    ContextMenuButton(
      label: "Create Invite",
      onPressed: () async {
        final result = await server.invites.create();

        showMessagePrompt(
          // ignore: use_build_context_synchronously
          context,
          const Text("Your Invite!"),
          Text("Your invite for ${server.name} is: ${result.id}"),
          extraButtons: [
            TextButton(
              onPressed: () {
                showCopyChip(context, result.id);
              },
              child: const Text("Copy"),
            ),
          ],
        );
      },
      icon: Icons.person_add,
    ),
    ContextMenuSeparator(),
    ContextMenuButton(
      label: "Leave Server",
      onPressed: () async {
        final result = await showConfirmPrompt(
          context,
          const Text("Leave Server"),
          Text("Are you sure you want to leave ${server.name}?"),
        );

        if (!result) return;

        await server.leave();
      },
      danger: true,
      icon: Icons.logout,
    ),
    ContextMenuSeparator(),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "Server ID", server.id.toString()),
  ];
}
