import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/stores/user_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/member.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/modals/user_viewer.dart';
import 'package:syrenity_client_flutter/widgets/show_dialog.dart';

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

    return Column(
      children: [
        Container(
          height: SyrenityTheme.topBarHeight,
          color: colors.surfaceContainer,
          // color: colors.inversePrimary,
          child: Center(child: const Text("Members")),
        ),
        Expanded(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            client.fileBase.from(
                              user.avatar ?? client.fileBase.badUrl,
                            )!,
                          ),
                        ),
                        title: Text(
                          user.username,
                          overflow: TextOverflow.ellipsis,
                        ),
                        hoverColor: colors.primary.withValues(alpha: 0.08),
                        onTap: () {
                          showSyDialog(context, UserViewerModal(user: user));
                        },
                      );
                    },
                  ),
                ),
              ),
              Container(
                height: SyrenityTheme.bottomBarHeight,
                color: colors.inversePrimary,
                // child: const Text("Test"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
