import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/widgets/avatar_with_status.dart';
import 'package:syrenity_client_flutter/widgets/table.dart';
import 'package:syrenity_client_flutter/widgets/todo.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ServerMemberSettingss extends StatefulWidget {
  const ServerMemberSettingss({super.key});

  @override
  State<ServerMemberSettingss> createState() => _ServerMemberSettingssState();
}

class _ServerMemberSettingssState extends State<ServerMemberSettingss> {
  List<SyMember> members = [];

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
      final fetchedRoles = await server.members.fetchAll();

      setState(() {
        members = fetchedRoles;
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
                  "Manage your members in your server",
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SyTable(
            columns: const [
              TableColumnData(name: "Name", flex: 2),
              TableColumnData(name: "Joined", flex: 1),
              TableColumnData(name: "Actions", flex: 1),
            ],

            rows:
                members.map((member) {
                  return [
                    Row(
                      children: [
                        AvatarWithStatus(userId: member.userId, size: 24),

                        const SizedBox(width: 8),

                        Text(
                          member.user?.username ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const Text("Add Later"),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        onPressed: () {
                          todo(context);
                        },
                        icon: const Icon(Icons.edit_rounded, size: 18),
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
