import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/main.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/syrenity_client/models/server.dart';
import 'package:syrenity_client_flutter/theme.dart';

class ServerBar extends StatefulWidget {
  const ServerBar({super.key});

  @override
  State<StatefulWidget> createState() => _ServerBarWidget();
}

class _ServerBarWidget extends State<ServerBar> {
  List<SyServer> servers = [];

  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() async {
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
                        if (setDrawerVisibility != null) {
                          setDrawerVisibility!(false);
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
              children:
                  servers.map((x) {
                    final isSelected = currentSettings.serverId == x.id;
                    final avatar = client.fileBase.from(x.avatar);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              context.read<CurrentSettingsState>().setServer(
                                x.id,
                              );
                            },
                            child: Tooltip(
                              waitDuration: Duration(milliseconds: 500),
                              message: x.name,
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: colors.secondaryContainer,
                                  backgroundImage:
                                      avatar != null
                                          ? NetworkImage(avatar)
                                          : null,
                                  child:
                                      avatar == null
                                          ? Text(x.id.toString())
                                          : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
