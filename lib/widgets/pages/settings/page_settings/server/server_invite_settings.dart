import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/widgets/table.dart';
import 'package:syrenity_client_flutter/widgets/todo.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';
import 'package:timeago/timeago.dart' as timeago;

class ServerInviteSettings extends StatefulWidget {
  const ServerInviteSettings({super.key});

  @override
  State<ServerInviteSettings> createState() => _ServerInviteSettingsState();
}

class _ServerInviteSettingsState extends State<ServerInviteSettings> {
  List<SyInvite> invites = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final settings = context.read<CurrentSettingsState>();
    final servers = context.read<ServerStore>();
    final serverId = settings.serverId;

    if (serverId != null) {
      final server = servers[serverId]!;
      final fetchedInvites = await server.fetchInvites();

      setState(() {
        invites = fetchedInvites;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: const Text(
                  "Here you can see all the invites to your server. You can view their details and manage them.",
                  softWrap: true,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  todo(context);
                },
                label: const Text("Create Invite (TODO!)"),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SyTable(
            columns: const [
              TableColumnData(name: "Name", flex: 2),
              TableColumnData(name: "Uses", flex: 2),
              TableColumnData(name: "Expires", flex: 2),
              TableColumnData(name: "Actions", flex: 1),
            ],

            rows:
                invites.map((role) {
                  final relative =
                      role.expiresIn == null
                          ? "Never"
                          : timeago.format(
                            role.createdAt.add(
                              Duration(milliseconds: role.expiresIn!),
                            ),
                            allowFromNow: true,
                          );

                  return [
                    Text(role.id),

                    Text("${role.uses} / ${role.maxUses ?? "∞"}"),

                    Text(relative),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        onPressed: () {
                          todo(context);
                        },
                        icon: const Icon(Icons.delete, size: 18),
                      ),
                    ),
                  ];
                }).toList(),
          ),
        ],
      ),
    );
  }
}
