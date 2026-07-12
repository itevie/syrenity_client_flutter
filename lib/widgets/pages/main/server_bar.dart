import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/app_client.dart';
import 'package:syrenity_client_flutter/main_callbacks.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/theme.dart';
import 'package:syrenity_client_flutter/widgets/context_menu.dart';
import 'package:syrenity_client_flutter/widgets/context_menus/server_cm.dart';
import 'package:syrenity_client_flutter/widgets/modals/join_create_server.dart';
import 'package:syrenity_client_flutter/widgets/pages/application_discovery.dart';
import 'package:syrenity_client_flutter/widgets/show_dialog.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ServerBar extends StatefulWidget {
  const ServerBar({super.key});

  @override
  State<StatefulWidget> createState() => _ServerBarWidget();
}

class _ServerBarWidget extends State<ServerBar> {
  List<SyServer> servers = [];
  void Function(SyMember)? memberAddCallback;
  void Function(SyMember)? memberRemoveCallback;

  @override
  void initState() {
    super.initState();

    memberAddCallback = (member) {
      if (member.userId != client.user.id) return;
      reload();
    };

    client.events.on(SyEvents.dispatchServerMemberAdd, memberAddCallback!);

    memberRemoveCallback = (member) {
      if (member.userId != client.user.id) return;
      reload();
    };

    client.events.on(
      SyEvents.dispatchServerMemberRemove,
      memberRemoveCallback!,
    );

    reload();
  }

  @override
  void dispose() {
    if (memberAddCallback != null) {
      client.events.off(SyEvents.dispatchServerMemberAdd, memberAddCallback!);
      memberAddCallback = null;
    }

    if (memberRemoveCallback != null) {
      client.events.off(
        SyEvents.dispatchServerMemberRemove,
        memberRemoveCallback!,
      );
      memberRemoveCallback = null;
    }

    if (channelOrderUpdateCallback != null) {
      client.events.off(
        SyEvents.dispatchChannelOrderUpdate,
        channelOrderUpdateCallback!,
      );
      channelOrderUpdateCallback = null;
    }

    super.dispose();
  }

  void reload() async {
    if (client.scaryUser == null) return;

    final loadedServers = await client.servers.fetchAll();

    setState(() {
      servers = loadedServers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final currentSettings = context.watch<CurrentSettingsState>();

    return Column(
      children: [
        Container(
          height: SyrenityTheme.topBarHeight,
          color: colors.surfaceContainer,
          // color: colors.inversePrimary,
          child: Center(
            child:
                isDesktop
                    ? Text("Sy")
                    : IconButton(
                      onPressed: () {
                        if (MainCallbacks.setDrawerVisibility != null) {
                          MainCallbacks.setDrawerVisibility!(false);
                        }
                      },
                      icon: const Icon(Icons.menu),
                    ),
          ),
        ),
        Expanded(
          child: Container(
            color: colors.primaryContainer,
            child: ListView(
              children: [
                ...servers.map((server) {
                  final isSelected = currentSettings.serverId == server.id;
                  final avatar = client.fileBase.from(server.avatar);

                  return ContextMenu(
                    asyncItems:
                        () async => makeServerContextMenu(context, server),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              if (MainCallbacks.setPage != null) {
                                MainCallbacks.setPage!(null);
                              }

                              server.members.fetchAll();

                              context.read<CurrentSettingsState>().setServer(
                                server.id,
                              );
                            },
                            child: Tooltip(
                              waitDuration: Duration(milliseconds: 500),
                              message: server.name,
                              child: CircleAvatar(
                                key: Key(server.id.toString()),
                                radius: 28,
                                backgroundColor:
                                    isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                child: CircleAvatar(
                                  key: Key(server.id.toString()),
                                  radius: 25,
                                  backgroundColor: colors.secondaryContainer,
                                  backgroundImage: NetworkImage(avatar),
                                  child: null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      // First icon
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            showSyDialog(context, JoinCreateServerDialog());
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: const Icon(Icons.add, size: 28),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12), // spacing between icons
                      // Second icon
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            if (MainCallbacks.setPage != null) {
                              MainCallbacks.setPage!(ApplicationDiscovery());
                            }

                            context.read<CurrentSettingsState>().setServer(
                              null,
                            );
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: const Icon(Icons.smart_toy, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
