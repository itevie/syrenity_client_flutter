import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syrenity_client_flutter/stores/current_settings_store.dart';
import 'package:syrenity_client_flutter/stores/server_store.dart';
import 'package:syrenity_client_flutter/widgets/table.dart';
import 'package:syrenity_flutter_client_api/syrenity_flutter_client_api.dart';

class ServerRoleSettings extends StatefulWidget {
  const ServerRoleSettings({super.key});

  @override
  State<ServerRoleSettings> createState() => _ServerRoleSettingsState();
}

class _ServerRoleSettingsState extends State<ServerRoleSettings> {
  List<SyRole> roles = [];

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
      final fetchedRoles = await server.fetchRoles();

      setState(() {
        roles = fetchedRoles;
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
                  "Roles allow you to give members certain permissions and decorations.",
                  softWrap: true,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                label: const Text("Add Role"),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SyTable(
            columns: const [
              TableColumnData(name: "Name", flex: 4),
              TableColumnData(name: "Members", flex: 2),
              TableColumnData(name: "Actions", flex: 1),
            ],

            rows:
                roles.map((role) {
                  return [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Color(
                            int.parse(
                              (role.color ?? "#FFFFFF").replaceFirst(
                                '#',
                                '0xff',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          role.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const Text("0", style: TextStyle(fontSize: 14)),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filled(
                        onPressed: () {},
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
