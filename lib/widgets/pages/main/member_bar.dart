import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/widgets/avatar_with_status.dart';
import 'package:syrenity_client_flutter/widgets/inline_username.dart';
import 'package:syrenity_client_flutter/widgets/modals/user_viewer.dart';
import 'package:syrenity_client_flutter/widgets/show_dialog.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class MemberBar extends StatefulWidget {
  const MemberBar({super.key});

  @override
  State<StatefulWidget> createState() => _MemberBarState();
}

class _MemberBarState extends State<MemberBar> {
  List<SyMember> members = [];
  int? _lastServerId;

  void load(SyServer server) async {
    final loadedMembers = await server.members.fetchAll();

    loadedMembers.sort((a, b) {
      final aHidden =
          a.status == null ||
          a.status?.visibility == null ||
          a.status!.visibility == "invisible";
      final bHidden =
          b.status == null ||
          b.status?.visibility == null ||
          b.status!.visibility == "invisible";

      if (aHidden && !bHidden) return 1;
      if (!aHidden && bHidden) return -1;
      return 0;
    });

    setState(() {
      members = loadedMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentSettings = context.watch<CurrentSettingsState>();
    final users = context.watch<UserStore>();

    final server =
        currentSettings.serverId == null
            ? null
            : context.select<ServerStore, SyServer?>(
              (x) => x[currentSettings.serverId!],
            );

    if (currentSettings.serverId != null &&
        currentSettings.serverId != _lastServerId) {
      _lastServerId = currentSettings.serverId;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        load(server!);
      });
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Material(
              color: colors.primaryContainer,
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, i) {
                  final member = members[i];
                  final user = users[member.userId];

                  if (user == null) {
                    return SizedBox();
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: AvatarWithStatus(userId: user.id, size: 16),
                    title: InlineUsername(user: user.id, bold: false),
                    hoverColor: colors.primary.withValues(alpha: 0.08),
                    onTap: () {
                      showSyDialog(context, UserViewerModal(user: user));
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
