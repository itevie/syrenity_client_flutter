import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/shared_prefs.dart';
import 'package:syrenity_client_flutter/stores/util.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/copy_something.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/main_setting_parts.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/page_settings/server_settings_parts.dart';
import 'package:syrenity_client_flutter/widgets/pages/settings/settings.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

List<ContextMenuItem> makeServerContextMenu(
  BuildContext context,
  SyServer server,
) {
  SyMember member;

  try {
    member = getMemberFromServer(context, server, client.user);
  } catch (e) {
    return [
      ContextMenuButton(label: e.toString(), onPressed: () {}, danger: true),
    ];
  }

  // final canDelete = server.ownerId == client.user.id;
  final canCreateInvites = member.hasPermission(SyPermission.createInvites);

  final isOwner = server.ownerId == client.user.id;

  return [
    if (canCreateInvites)
      ContextMenuButton(
        label: "Create Invite",
        onPressed: () async {
          final result = await server.invites.create();

          await showInvitePromptBottomSheet(context, server, result.id);
        },
        icon: Icons.person_add,
      ),
    ContextMenuSeparator(),
    if (!isOwner)
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
    ContextMenuButton(
      label: "Manage",
      icon: Icons.edit,
      onPressed: () {
        navigate(
          context,
          SettingsPage(
            name: "${server.name} Settings",
            sections: [
              ServerSettingsParts.about(context),
              ServerSettingsParts.members(context),
              ServerSettingsParts.roles(context),
              ServerSettingsParts.invites(context),
              ServerSettingsParts.details(context),
            ],
          ),
        );
      },
    ),
    ContextMenuSeparator(),
    if (SettingsStorage.instance.getSetting<bool>(SettingKeys.developerMode))
      makeCopyContextMenuButton(context, "Server ID", server.id.toString()),
  ];
}

Future<void> showInvitePromptBottomSheet(
  BuildContext context,
  SyServer server,
  String inviteId,
) async {
  await showDialog(
    context: context,
    builder:
        (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: InvitePromptSheet(
              serverName: server.name,
              inviteId: inviteId,
            ),
          ),
        ),
  );
}

class InvitePromptSheet extends StatelessWidget {
  final String serverName;
  final String inviteId;

  const InvitePromptSheet({
    super.key,
    required this.serverName,
    required this.inviteId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invite Created",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Share this invite for $serverName.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      inviteId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'RobotoMono',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      showCopyChip(context, inviteId);
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text("Copy"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
